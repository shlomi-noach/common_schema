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

_proc_body: BEGIN
  SET @_execute_query := TRIM(execute_query);
  IF CHAR_LENGTH(@_execute_query) = 0 THEN
    -- An empty statement
    -- This can happen as result of splitting by semicolon ';'
    LEAVE _proc_body;
  END IF;

  set @common_schema_rowcount := NULL;
  
  IF @common_schema_dryrun > 0 THEN
    SELECT @_execute_query AS 'exec_single: @common_schema_dryrun';
  ELSE
    IF @common_schema_verbose THEN
	  SELECT @_execute_query AS 'exec_single: @common_schema_verbose';
    END IF;
  
    PREPARE st FROM @_execute_query;
    EXECUTE st;
    SET @common_schema_rowcount := ROW_COUNT();
    DEALLOCATE PREPARE st;    
  END IF;
END $$

DELIMITER ;
