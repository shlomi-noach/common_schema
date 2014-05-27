-- 
-- Returns first day of quarter of given datetime, as DATE object
-- 
-- Example:
--
-- SELECT start_of_quarter('2010-08-24 11:13:42');
-- Returns: '2010-07-01' (as DATE)
--

DELIMITER $$

DROP FUNCTION IF EXISTS start_of_quarter $$
CREATE FUNCTION start_of_quarter(dt DATETIME) RETURNS DATE 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Returns first day of quarter of given datetime, as DATE object'

BEGIN
  RETURN DATE(dt) - INTERVAL (MONTH(dt) -1) MONTH - INTERVAL (DAYOFMONTH(dt) - 1) DAY + INTERVAL (QUARTER(dt) - 1) QUARTER;
END $$

DELIMITER ;
