-- 
-- Return the number of seconds represented by the given short form
-- 
-- - shorttime: a string representing a time length. It is a number followed by a time ebbreviation, 
--   one of 's', 'm', 'h', standing for seconds, minutes, hours respectively.
--   Examples: '15s', '3m', '2h' 
-- 
-- The function returns NULL on invalid input: any input which is not in short-time format,
-- including plain numbers (to emphasize: the input '12' is invalid)
--
-- Example:
--
-- SELECT shorttime_to_seconds('2h');
-- Returns: 7200
--

DELIMITER $$

DROP FUNCTION IF EXISTS shorttime_to_seconds $$
CREATE FUNCTION shorttime_to_seconds(shorttime VARCHAR(10) CHARSET ascii) RETURNS INT UNSIGNED 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Return a 64 bit CRC of given input, as unsigned big integer'

BEGIN
  declare numeric_value INT UNSIGNED DEFAULT NULL;
  
  if shorttime is NULL then
    return NULL;
  end if;
  if not shorttime rlike '^[0-9]+[smh]$' then
    return NULL;
  end if;

  set numeric_value := CAST(LEFT(shorttime, CHAR_LENGTH(shorttime) - 1) AS UNSIGNED);
  case RIGHT(shorttime, 1)
    when 's' then set numeric_value := numeric_value*1;
    when 'm' then set numeric_value := numeric_value*60;
    when 'h' then set numeric_value := numeric_value*60*60;
  end case;
  return numeric_value;
END $$

DELIMITER ;
