-- 
-- Returns first day of week, Sunday based, of given datetime, as DATE object
-- 
-- Example:
--
-- SELECT start_of_week_sunday('2011-03-24 11:13:42');
-- Returns: '2011-03-20' (which is Sunday, as DATE)
--

DELIMITER $$

DROP FUNCTION IF EXISTS start_of_week_sunday $$
CREATE FUNCTION start_of_week_sunday(dt DATETIME) RETURNS DATE 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Returns Sunday-based first day of week of given datetime'

BEGIN
  RETURN DATE(dt) - INTERVAL (WEEKDAY(dt) + 1) DAY;
END $$

DELIMITER ;


