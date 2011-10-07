-- 
-- Returns 1 when given input starts with SELECT, 0 otherwise
-- 
-- This is heuristic only, and is used to diagnose input to various routines.
-- 
-- Example:
--
-- SELECT _is_select_query('SELECT 3 FROM DUAL');
-- Returns: 1
--

DELIMITER $$

DROP FUNCTION IF EXISTS _is_select_query $$
CREATE FUNCTION _is_select_query(input LONGTEXT CHARSET utf8) RETURNS TINYINT UNSIGNED
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Returns 1 when given input starts with SELECT'

BEGIN
  RETURN (LOCATE('select', LOWER(trim_wspace(input))) = 1);
END $$

DELIMITER ;
