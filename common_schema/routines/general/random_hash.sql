-- 
-- Generate random hash string
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS random_hash $$
CREATE FUNCTION random_hash() RETURNS CHAR(40) CHARSET ascii 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Generate random hash string'

begin
	declare result CHAR(40) CHARSET ascii;
	select 
	  SHA1(
	    CONCAT_WS(',', @@server_id, SYSDATE(), RAND(), GROUP_CONCAT(VARIABLE_VALUE))
	  )
	from
	  INFORMATION_SCHEMA.GLOBAL_STATUS
	into result;
	return result;
end $$

DELIMITER ;
