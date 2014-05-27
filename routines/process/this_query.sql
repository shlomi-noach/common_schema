-- 
-- Returns the current query executed by this thread.
-- The text of current query will, of course, include the call to this_query() itself.
-- It may be useful in passing query's text to text-parsing functions which can further
-- make decisions while executing the query.
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS this_query $$
CREATE FUNCTION this_query() RETURNS LONGTEXT CHARSET utf8 
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Return current query'

BEGIN
  return (SELECT INFO FROM INFORMATION_SCHEMA.PROCESSLIST WHERE ID = CONNECTION_ID());
END $$

DELIMITER ;
