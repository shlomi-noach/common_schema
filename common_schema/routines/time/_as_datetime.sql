-- 
-- Checks whether the given string is a valid datetime.
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS _as_datetime $$
CREATE FUNCTION _as_datetime(txt TINYTEXT) RETURNS DATETIME
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Convert given text to DATETIME or NULL.'

BEGIN
  declare continue handler for SQLEXCEPTION return NULL; 
  RETURN (txt + interval 0 second);
END $$

DELIMITER ;
