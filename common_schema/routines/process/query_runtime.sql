-- 
-- Returns the number of seconds this query has been running for so far.
-- On servers supporting subsecond time resolution, this results with a 
-- floating point value.
-- On servers with single second resolution this results with a truncated integer.
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS query_runtime $$
CREATE FUNCTION query_runtime() RETURNS DOUBLE 
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Return current query runtime'

BEGIN
  return TIMESTAMPDIFF(MICROSECOND, NOW(), SYSDATE()) / 1000000.0;
END $$

DELIMITER ;
