-- 
-- Returns DATETIME of beginning of round hour of given DATETIME.
-- 
-- Example:
--
-- SELECT start_of_hour('2011-03-24 11:17:08');
-- Returns: '2011-03-24 11:00:00' (as DATETIME)
--

DELIMITER $$

DROP FUNCTION IF EXISTS start_of_hour $$
CREATE FUNCTION start_of_hour(dt DATETIME) RETURNS DATETIME
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Returns DATETIME of beginning of round hour of given DATETIME.'

BEGIN
  RETURN DATE(dt) + INTERVAL HOUR(dt) HOUR;
END $$

DELIMITER ;
