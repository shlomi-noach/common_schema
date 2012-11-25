--
--
--

delimiter //

drop procedure if exists _expand_single_variable //

create procedure _expand_single_variable(
   in   id_from            int unsigned,
   in   id_to              int unsigned,
   inout   variable_token     text charset utf8,
   in   should_execute_statement tinyint unsigned
)
comment 'Returns an expanded value'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  declare expanded_variable_name TEXT CHARSET utf8;
  
  set expanded_variable_name := _extract_expanded_query_script_variable_name(variable_token);
  if expanded_variable_name is null then
    -- Token is not expanded variable... return as it
    leave main_body;
  end if;
  
  -- Token is expanded variable. Try to match it against current from->to scope.
  if not should_execute_statement then
    leave main_body;
  end if;
  
  call _take_local_variables_snapshot(expanded_variable_name);
 
  SELECT 
    MIN(_qs_variables.value_snapshot)
  FROM 
    _sql_tokens 
    LEFT JOIN _qs_variables ON (
      /* Try to match an expanded  query script variable */
      (state = 'expanded query_script variable' AND _extract_expanded_query_script_variable_name(token) = _qs_variables.variable_name AND _qs_variables.variable_name  = expanded_variable_name) /* expanded */ 
      and (id_from between _qs_variables.declaration_id and _qs_variables.scope_end_id)
    )
  where 
    (id between id_from and id_to) 
  INTO 
    variable_token;
end;
//

delimiter ;
