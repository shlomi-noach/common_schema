--
-- Executes a given query or semicolon delimitied list of queries
-- Input to this procedure is either:
-- - A single query (no limitation on query)
-- - A list of queries, separated by semicolon (;) and ending with a semicolon. 
--   Queries must not include semicolon (e.g. embedded within a string)
--
-- This procedure calls upon exec_single(), which means it will:
-- - skip empty queries (whitespace only)
-- - Avoid executing query when @common_schema_dryrun is set (query is merely printed)
-- - Include verbose message when @common_schema_verbose is set
-- - Set @common_schema_rowcount to reflect the query's ROW_COUNT(). In case of multiple queries,
--   the value represents the ROW_COUNT() of last query.
--
-- Example:
--
-- CALL exec('UPDATE world.City SET Population = Population + 1 WHERE Name =\'Paris\'');
-- CALL exec('CREATE TABLE world.City2 LIKE world.City; INSERT INTO world.City2 SELECT * FROM world.City;');
--

DELIMITER $$

DROP PROCEDURE IF EXISTS exec $$
CREATE PROCEDURE exec(IN execute_queries TEXT CHARSET utf8) 
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT ''

BEGIN
  DECLARE num_query_tokens, queries_loop_counter TINYINT UNSIGNED DEFAULT 0;
  DECLARE single_query TEXT CHARSET utf8; 
  
  SET execute_queries := TRIM(execute_queries);
  IF RIGHT(execute_queries, 1) = ';' THEN
    -- There are multiple statements
    -- The semicolon ';' is assumed to split queries. It must not appear within a query
    SET num_query_tokens := get_num_tokens(execute_queries, ';');
    SET queries_loop_counter := 0;
    WHILE queries_loop_counter < num_query_tokens DO
      SET single_query := split_token(execute_queries, ';', queries_loop_counter + 1);
      call exec_single(single_query);
      SET queries_loop_counter := queries_loop_counter + 1;
    END WHILE;    
  ELSE
    -- There is a single statement.
    -- We don't even attempt a trivial split, because we now allow a semicolon ';' to appear within the text.
    call exec_single(execute_queries);
  END IF;
END $$


DELIMITER ;
