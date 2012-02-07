-- 
-- Returns the number of seconds elapsed since QueryScript execution began.
-- Calling this function only makes since from within a script.
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS script_runtime $$
CREATE FUNCTION script_runtime() RETURNS DOUBLE 
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Return current script runtime seconds'

BEGIN
  return TIMESTAMPDIFF(MICROSECOND, @_common_schema_script_start_timestamp, SYSDATE()) / 1000000.0;
END $$

DELIMITER ;
