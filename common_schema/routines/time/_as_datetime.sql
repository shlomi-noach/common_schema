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
  -- workaround for Issue 61:
  -- The _as_datetime() function misbehaves with timestamps the look look like real dates.
  -- UNIX_TIMESTAMP('2014-05-28') = 1401220800. And _as_datetime('1401220800') = '2014-01-22 08:00:00'.
  if txt RLIKE '^[0-9]{10}$' then
    return NULL;
  end if;
  RETURN (txt + interval 0 second);
END $$

DELIMITER ;
