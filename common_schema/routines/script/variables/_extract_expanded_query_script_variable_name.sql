--
--
--

DELIMITER $$

DROP FUNCTION IF EXISTS _extract_expanded_query_script_variable_name $$
CREATE FUNCTION _extract_expanded_query_script_variable_name(
	expanded_query_script_variable TEXT CHARSET ascii) RETURNS TEXT CHARSET ascii 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Get name of qs variable from expanded format'

begin
  -- :${my_var} turns into $my_var
  if expanded_query_script_variable LIKE ':${%}' then
    return CONCAT('$', SUBSTRING(expanded_query_script_variable, 4, CHAR_LENGTH(expanded_query_script_variable) - 4));
  end if;
  -- :$my_var turns into $my_var
  if expanded_query_script_variable LIKE ':$%' then
    return SUBSTRING(expanded_query_script_variable, 2);
  end if;
  return NULL;
end $$

DELIMITER ;
