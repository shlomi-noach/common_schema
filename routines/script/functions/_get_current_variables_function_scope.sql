-- 
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS _get_current_variables_function_scope $$
CREATE FUNCTION _get_current_variables_function_scope() RETURNS VARCHAR(80) CHARSET ascii 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Return current QS function scope'

begin
	return SUBSTRING_INDEX(@_common_schema_script_function_scope, ',', 1);
end $$

DELIMITER ;
