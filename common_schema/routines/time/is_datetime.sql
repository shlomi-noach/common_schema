-- 
-- Checks whether the given string is a valid datetime.
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS is_datetime $$
CREATE FUNCTION is_datetime(txt TINYTEXT) RETURNS TINYINT UNSIGNED
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Returns DATETIME of beginning of round hour of given DATETIME.'

BEGIN
  RETURN (CAST(txt AS DATETIME) is not null);
END $$

DELIMITER ;
