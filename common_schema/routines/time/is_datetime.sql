-- 
-- Checks whether the given string is a valid datetime.
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS is_datetime $$
CREATE FUNCTION is_datetime(txt TINYTEXT) RETURNS TINYINT UNSIGNED
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Checks whether given txt is a valid DATETIME.'

BEGIN
  declare continue handler for SQLEXCEPTION return false; 
  RETURN (txt + interval 0 second is not null);
END $$

DELIMITER ;
