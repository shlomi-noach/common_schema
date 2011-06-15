-- 
-- Returns first day of year of given datetime, as DATE object
-- 
-- Example:
--
-- SELECT start_of_year('2011-03-24 11:13:42');
-- Returns: '2011-01-01' (as DATE)
--

DELIMITER $$

DROP FUNCTION IF EXISTS start_of_year $$
CREATE FUNCTION start_of_year(dt DATETIME) RETURNS DATE 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Returns first day of month of given datetime, as DATE object'

BEGIN
  RETURN DATE(dt) - INTERVAL (MONTH(dt) -1) MONTH - INTERVAL (DAYOFMONTH(dt) - 1) DAY;
END $$

DELIMITER ;
