--
-- Executes a given query.
-- Given a query, this procedure executes it. Essentially, is uses dynamic SQL to invoke
-- the query.
-- The procedure will do the following:
-- - skip any operation when query is empty (whitespace only)
-- - Avoid executing query when @common_schema_dryrun is set (query is merely printed)
-- - Include verbose message when @common_schema_verbose is set
-- - Set @common_schema_rowcount to reflect the query's ROW_COUNT()
--
-- Example:
--
-- CALL exec('UPDATE world.City SET Population = Population + 1 WHERE Name =\'Paris\'');
--

DELIMITER $$

DROP PROCEDURE IF EXISTS exec_single $$
CREATE PROCEDURE exec_single(IN execute_query TEXT CHARSET utf8) 
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT ''

_proc_body: begin
  set @_execute_query := TRIM(execute_query);
  if CHAR_LENGTH(@_execute_query) = 0 then
    -- An empty statement
    -- This can happen as result of splitting by semicolon ';'
    leave _proc_body;
  end if;

  set @common_schema_rowcount := NULL;
  
  if @common_schema_dryrun > 0 then
    SELECT @_execute_query AS 'exec_single: @common_schema_dryrun';
  else
    if @common_schema_verbose then
	  SELECT @_execute_query AS 'exec_single: @common_schema_verbose';
    end if;
  
    PREPARE st FROM @_execute_query;
    EXECUTE st;
    set @common_schema_rowcount := ROW_COUNT();
    DEALLOCATE PREPARE st;    
  end if;
end $$

DELIMITER ;
