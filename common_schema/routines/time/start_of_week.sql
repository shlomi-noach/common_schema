-- 
-- Returns first day of week of given datetime (i.e. start of Monday), as DATE object
-- 
-- Example:
--
-- SELECT start_of_week('2011-03-24 11:13:42');
-- Returns: '2011-03-21' (which is Monday, as DATE)
--

DELIMITER $$

DROP FUNCTION IF EXISTS start_of_week $$
CREATE FUNCTION start_of_week(dt DATETIME) RETURNS DATE 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Returns Monday-based first day of week of given datetime'

BEGIN
  RETURN DATE(dt) - INTERVAL WEEKDAY(dt) DAY;
END $$

DELIMITER ;
