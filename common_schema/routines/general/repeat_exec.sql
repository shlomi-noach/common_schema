--
-- Repeatedly executes given query or queries until some condition holds.
--
-- The procedure accpets:
--
-- - interval_seconds: sleep time between executions. 
--   First sleep occurs afetr first execution of query or queries.
--   Value of 0 or NULL indicate no sleep
-- - execute_queries: query or queries, in similar format as that of exec()
-- - stop_condition: one of the following:
--   - NULL: no stop condition; repeat infinitely
--   - 0: repeat until no rows are affected by query
--   - n (positive number): limit by number of iterations
--   - Simple time format: limit by total accumulating runtime. 
--     Time units are seconds, minutes, hours. Examples: '15s', '3m', '2h'
--  
-- This procedure uses exec() which means it will:
-- - skip empty queries (whitespace only)
-- - Avoid executing query when @common_schema_dryrun is set (query is merely printed)
-- - Include verbose message when @common_schema_verbose is set
--
-- Examples:
--
-- CALL repeat_exec(3, 'DELETE FROM world.Country WHERE Continent != \'Africa\' LIMIT 10', 0); 
-- CALL repeat_exec(60, 'FLUSH LOGS', '30m'); 
--

DELIMITER $$

DROP PROCEDURE IF EXISTS repeat_exec $$
CREATE PROCEDURE repeat_exec(interval_seconds DOUBLE, execute_queries TEXT CHARSET utf8, stop_condition VARCHAR(12) CHARSET ascii) 
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT ''

begin
  declare repeat_complete TINYINT UNSIGNED DEFAULT 0;
  declare num_iterations INT UNSIGNED DEFAULT 0;
  declare stop_iterations INT UNSIGNED DEFAULT NULL;
  declare stop_seconds INT UNSIGNED DEFAULT NULL;
  declare start_timestamp TIMESTAMP DEFAULT NOW();

  set stop_seconds := shorttime_to_seconds(stop_condition);
  if stop_condition rlike '^[0-9]+$' then
    set stop_iterations := CAST(stop_condition AS UNSIGNED INTEGER);
  end if;
  
  repeat
    call exec(execute_queries);
    set num_iterations := num_iterations + 1;
    
    if stop_condition = '0' then
      if @common_schema_rowcount = 0 then
        set repeat_complete := 1;
      end if;
    elseif stop_seconds IS NOT NULL then
      if TIMESTAMPDIFF(SECOND, start_timestamp, SYSDATE()) >= stop_seconds then 
	    set repeat_complete := 1;
	  end if;
    elseif IFNULL(stop_iterations, 0) > 0 then
      if num_iterations >= stop_iterations then
        set repeat_complete := 1;
      end if;
    elseif stop_condition IS NULL then
      -- no limitation; the following is just a placeholder
      set repeat_complete := 0;
    else
      -- unknown condition
      set repeat_complete := 1;
      set @common_schema_error := 'repeat_exec: invalid stop_condition';
    end if;
    
    if repeat_complete = 0 then
      if IFNULL(interval_seconds, 0) > 0 then
        DO SLEEP(interval_seconds);
      end if;
    end if;
  until repeat_complete
  end repeat;
end $$

DELIMITER ;
