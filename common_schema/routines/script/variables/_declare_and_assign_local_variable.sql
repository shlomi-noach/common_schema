--
--
--

delimiter //

drop procedure if exists _declare_and_assign_local_variable //

create procedure _declare_and_assign_local_variable(
   in   id_from      int unsigned,
   in   id_to        int unsigned,
   in   statement_id_from      int unsigned,
   in   assign_id    int unsigned,
   in   statement_id_to      int unsigned,
   in   depth int unsigned,
   in should_execute_statement tinyint unsigned
)
comment 'Declares local variables'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  declare local_variable varchar(65) charset ascii;
  declare user_defined_variable_name varchar(65) charset ascii;
  declare set_expression text charset utf8;
  declare set_statement text charset utf8;
  declare declaration_is_new tinyint unsigned default 0;
    
  call _expect_state(statement_id_from, id_to, 'query_script variable', true, @_common_schema_dummy, local_variable);

  SELECT (COUNT(*) = 0) FROM _qs_variables WHERE declaration_id = id_from INTO declaration_is_new;
  if declaration_is_new then
    set user_defined_variable_name := CONCAT('@__qs_local_var_', session_unique_id());
    call _declare_local_variable(id_from, statement_id_to, id_to, depth, local_variable, user_defined_variable_name, TRUE);
  end if;
  
  if should_execute_statement then
    call _expand_statement_variables(assign_id+1, statement_id_to, set_expression, @_common_schema_dummy, should_execute_statement);
  
    -- select GROUP_CONCAT(token order by id separator '') from _sql_tokens where id between assign_id+1 AND statement_id_to-1 into set_expression;
    select CONCAT('SET ', mapped_user_defined_variable_name, ' := ', set_expression) from _qs_variables where variable_name = local_variable and declaration_depth = depth into set_statement;
    call exec(set_statement);
    -- SELECT GROUP_CONCAT('SET ', mapped_user_defined_variable_name, ' := NULL ' SEPARATOR ';') FROM _qs_variables WHERE declaration_depth = depth INTO reset_query;
    
  end if;
end;
//

delimiter ;
