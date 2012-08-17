--
--
--

delimiter //

drop procedure if exists _expand_statement_variables //

create procedure _expand_statement_variables(
   in   id_from      int unsigned,
   in   id_to      int unsigned,
   out  expanded_statement text charset utf8,
   out  expanded_variables_found tinyint unsigned,
   in should_execute_statement tinyint unsigned
)
comment 'Returns an expanded script statement'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  declare expanded_variables TEXT CHARSET utf8;
  
  SELECT GROUP_CONCAT(DISTINCT _extract_expanded_query_script_variable_name(token)) from _sql_tokens where (id between id_from and id_to) and (state = 'expanded query_script variable') INTO expanded_variables;
  set expanded_variables_found := (expanded_variables IS NOT NULL); 
  if expanded_variables_found then
    -- Expanded variables found.
    if should_execute_statement then
      call _take_local_variables_snapshot(expanded_variables);
    end if;
    SELECT GROUP_CONCAT(IF(_qs_variables.variable_name IS NOT NULL, _qs_variables.value_snapshot, token) ORDER BY id SEPARATOR '') FROM _sql_tokens LEFT JOIN _qs_variables ON (state = 'expanded query_script variable' AND _extract_expanded_query_script_variable_name(token) = _qs_variables.variable_name) where (id between id_from and id_to) INTO expanded_statement;
  else
    -- No expanded variables found. Read the query directly from tokens.
    SELECT GROUP_CONCAT(token ORDER BY id SEPARATOR '') FROM _sql_tokens where (id between id_from and id_to) INTO expanded_statement;
  end if;
end;
//

delimiter ;
