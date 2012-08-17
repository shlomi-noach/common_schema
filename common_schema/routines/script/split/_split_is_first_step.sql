-- 
-- 
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS _split_is_first_step $$
CREATE FUNCTION _split_is_first_step() RETURNS TINYINT UNSIGNED
NO SQL
SQL SECURITY INVOKER
COMMENT ''

begin
  return @_split_is_first_step_flag;
end $$

DELIMITER ;
