-- 
-- Return a qualified MySQL grantee (account) based on user and host.
-- 
-- It is a simple convenience function which wraps up the single quotes around the components
--
-- Example:
--
-- SELECT mysql_grantee('web_user', '192.128.0.%');
-- Returns (text): 'web_user'@'192.128.0.%'
-- 
DELIMITER $$

DROP FUNCTION IF EXISTS mysql_grantee $$
CREATE FUNCTION mysql_grantee(mysql_user char(80) CHARSET utf8, mysql_host char(60) CHARSET utf8) RETURNS VARCHAR(100) CHARSET utf8 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Return a qualified MySQL grantee name'

BEGIN
  RETURN CONCAT('''', mysql_user, '''@''', mysql_host, '''');
END $$

DELIMITER ;
