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

  SELECT GROUP_CONCAT(DISTINCT _extract_expanded_query_script_variable_name(token)) from _sql_tokens where (id between id_from and id_to) and (state = 'expanded query_script variable') INTO @_expanded_variables;
  set expanded_variables=@_expanded_variables;
  set expanded_variables_found := (expanded_variables IS NOT NULL);
  if expanded_variables_found and should_execute_statement then
    call _take_local_variables_snapshot(expanded_variables);
  end if;
  SELECT
    GROUP_CONCAT(
      case
        when _qs_variables_this_function.mapped_user_defined_variable_name IS NOT NULL then
          case
            when state = 'expanded query_script variable' then _qs_variables_this_function.value_snapshot /* expanded */
            else _qs_variables_this_function.mapped_user_defined_variable_name /* non-expanded */
          end
        when _qs_variables_global.mapped_user_defined_variable_name IS NOT NULL then
          case
            when state = 'expanded query_script variable' then _qs_variables_global.value_snapshot /* expanded */
            else _qs_variables_global.mapped_user_defined_variable_name /* non-expanded */
          end
        else token /* not a query script variable at all */
      end
      ORDER BY id ASC SEPARATOR ''
    )
  FROM
    _sql_tokens
    LEFT JOIN _qs_variables AS _qs_variables_this_function ON (
      /* Try to match a query script variable, or an expanded  query script variable */
      (
        (state = 'expanded query_script variable' AND _extract_expanded_query_script_variable_name(token) = _qs_variables_this_function.variable_name) /* expanded */
        or (state = 'query_script variable' AND token = _qs_variables_this_function.variable_name) /* non-expanded */
      )
      and (id_from between _qs_variables_this_function.declaration_id and _qs_variables_this_function.scope_end_id)
      and _qs_variables_this_function.function_scope = _get_current_variables_function_scope()
    )
    LEFT JOIN _qs_variables AS _qs_variables_global ON (
      /* Try to match a query script variable, or an expanded  query script variable */
      (
        (state = 'expanded query_script variable' AND _extract_expanded_query_script_variable_name(token) = _qs_variables_global.variable_name) /* expanded */
        or (state = 'query_script variable' AND token = _qs_variables_global.variable_name) /* non-expanded */
      )
      and (id_from between _qs_variables_global.declaration_id and _qs_variables_global.scope_end_id)
      and _qs_variables_global.function_scope = ''
    )
  where
    (id between id_from and id_to)
  into
    @_expanded_statement;
  set expanded_statement=@_expanded_statement;
  set expanded_statement := trim_wspace(expanded_statement);
end;
//

delimiter ;
