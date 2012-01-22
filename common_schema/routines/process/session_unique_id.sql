-- 
-- Returns an integer unique to this session 
--

DELIMITER $$

DROP FUNCTION IF EXISTS session_unique_id $$
CREATE FUNCTION session_unique_id() RETURNS INT UNSIGNED
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Returns unique ID within this session'

BEGIN
  set @_common_schema_session_unique_id := IFNULL(@_common_schema_session_unique_id, 0) + 1;
  return @_common_schema_session_unique_id;
END $$

DELIMITER ;
