--
-- Executes a given query or semicolon delimited list of queries
-- Input to this procedure is either:
-- - A single query 
-- - A list of queries, separated by semicolon (;), possibly ending with a semicolon. 
--
-- This procedure calls upon exec_single(), which means it will:
-- - skip empty queries (whitespace only)
-- - Avoid executing query when @common_schema_dryrun is set (query is merely printed)
-- - Include verbose message when @common_schema_verbose is set
-- - Set @common_schema_rowcount to reflect the query's ROW_COUNT(). In case of multiple queries,
--   the value represents the ROW_COUNT() of last query.
--
-- Examples:
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

begin
  declare num_query_tokens, queries_loop_counter TINYINT UNSIGNED DEFAULT 0;
  declare single_query TEXT CHARSET utf8; 
  declare internal_token VARCHAR(32) CHARSET utf8 DEFAULT '[\0_cs_::;::\0]';
  
  -- There may be multiple statements
  set execute_queries := _retokenized_queries(execute_queries);
  set num_query_tokens := get_num_tokens(execute_queries, internal_token);
  set queries_loop_counter := 0;
  while queries_loop_counter < num_query_tokens do
    set single_query := split_token(execute_queries, internal_token, queries_loop_counter + 1);
    call exec_single(single_query);
    set queries_loop_counter := queries_loop_counter + 1;
  end while;    
end $$

DELIMITER ;
