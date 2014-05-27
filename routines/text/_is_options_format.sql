-- 
-- Extract value from options dictionary based on key
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS _is_options_format $$
CREATE FUNCTION _is_options_format(options TEXT CHARSET utf8) 
  returns tinyint unsigned
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Return value of option in JS options format'

begin
  if options is null then
    return false;
  end if;
  return (trim_wspace(options) RLIKE '^{.*}$') is true;
end $$

DELIMITER ;
