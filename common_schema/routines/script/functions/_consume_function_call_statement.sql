--
-- consume/invoke a QueryScript function:
-- - validate function exists
-- - validate call syntax
-- - validate number of arguments
-- - declare function arguments, push function call values into arguments
-- - execute function body
--

delimiter //

drop procedure if exists _consume_function_call_statement //

create procedure _consume_function_call_statement(
   in   id_from      int unsigned,
   in   statement_id_from      int unsigned,
   in   statement_id_to      int unsigned,
   in   depth int unsigned,
   in should_execute_statement tinyint unsigned
)
comment 'Invoke a QS function'
language SQL
deterministic
reads sql data
sql security invoker
main_body: begin
    declare matched_function_name text charset utf8;
    declare consumed_to_id int unsigned;
    declare statement_arguments text charset utf8;
    declare expanded_variables_found tinyint unsigned;
	declare num_arguments int unsigned;
	declare function_arguments_declaration_id int unsigned;
	declare function_scope_start_id int unsigned;
	declare function_scope_end_id int unsigned;
	declare expected_num_arguments int unsigned;
	declare imploded_function_arguments text charset utf8;
	declare push_query text charset utf8;
	declare mapped_user_defined_variable_names text charset utf8;
	declare counter int unsigned;
	
    call _expect_state(statement_id_from, statement_id_to, 'alpha|alphanum', true, consumed_to_id, matched_function_name);
	call _expect_function_exists(statement_id_from, matched_function_name);
    if should_execute_statement then
      set statement_id_from := consumed_to_id + 1;
      call _skip_spaces(statement_id_from, statement_id_to);
	  call _expand_statement_variables(statement_id_from, statement_id_to, statement_arguments, expanded_variables_found, should_execute_statement);
	  set statement_arguments := trim_wspace(statement_arguments);
	  -- validate syntax
	  if statement_arguments not rlike '^[(].*[)]$' then
	  	call _throw_script_error(id_from, 'Expected "(...)" on function invocation');
	  end if;
	  set statement_arguments := unwrap(statement_arguments);
	  set statement_arguments := trim_wspace(statement_arguments);

	  -- grab hold of info:
	  select 
	      count_function_arguments,
	      function_arguments,
	      arguments_declaration_id,
	      scope_start_id, 
	      scope_end_id
	    from
	      _qs_functions
	    where
	      function_name = matched_function_name
	    into 
	      expected_num_arguments,
	      imploded_function_arguments,
	      function_arguments_declaration_id,
	      function_scope_start_id,
	      function_scope_end_id
	    ;
	  -- validate num arguments provided is same as in function declaration
	  if statement_arguments = '' then
	    set num_arguments := 0;
	  else
	    select 
	  	    count(*) 
	  	  from 
	  	    _sql_tokens,
	  	    (select level as arguments_level from _sql_tokens where id = statement_id_from) sel_arguments_level
	  	  where 
	  	    id >= statement_id_from and id <= statement_id_to
	  	    and state = 'comma'
	  	    and level = arguments_level
	  	  into num_arguments;
        set num_arguments := num_arguments + 1;
	  end if;
	  
	  if num_arguments != expected_num_arguments then
	  	call _throw_script_error(id_from, concat('Expected ', expected_num_arguments, ' arguments, found ', num_arguments));
	  end if;
	  
	  call _declare_local_variables(function_arguments_declaration_id, function_scope_end_id, function_scope_end_id, depth, imploded_function_arguments);

	  -- push values into function arguments:
	  select 
	      group_concat(mapped_user_defined_variable_name order by mapped_user_defined_variable_name separator ',')
	    from _qs_variables
	    where declaration_id = function_arguments_declaration_id
	    into mapped_user_defined_variable_names;
	  set push_query := concat('select ', statement_arguments, ' into ', mapped_user_defined_variable_names);
	  call exec(push_query);

	  -- And execute function code!
	  call _consume_statement(function_scope_start_id, function_scope_end_id, TRUE, @_common_schema_dummy, depth+1, TRUE);
    end if;
end;
//

delimiter ;
