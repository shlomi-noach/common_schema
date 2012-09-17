--
--
--

delimiter //

drop procedure if exists _consume_foreach_expression //

create procedure _consume_foreach_expression(
   in   id_from      int unsigned,
   in   id_to      int unsigned,
   out  consumed_to_id int unsigned,
   in   depth int unsigned,
   out  collection text charset utf8,
   out  variables_array_id int unsigned,
   out  variables_delaration_id int unsigned,
   in should_execute_statement tinyint unsigned
)
comment 'Reads foreach() expression'
language SQL
deterministic
reads sql data
sql security invoker
main_body: begin
    declare first_state text;
    declare expression_level int unsigned;
    declare id_end_expression int unsigned default NULL; 
    declare id_end_variables_definition int unsigned default NULL; 
    
    call _skip_spaces(id_from, id_to);
    SELECT level, state FROM _sql_tokens WHERE id = id_from INTO expression_level, first_state;

    if (first_state != 'left parenthesis') then
      call _throw_script_error(id_from, 'Expected "(" on foreach expression');
    end if;
    
    SELECT MIN(id) FROM _sql_tokens WHERE id > id_from AND state = 'right parenthesis' AND level = expression_level INTO id_end_expression;
  	if id_end_expression IS NULL then
	  call _throw_script_error(id_from, 'Unmatched "(" parenthesis');
	end if;
	
	-- Detect the positions where variables are declared
    SELECT MIN(id) FROM _sql_tokens WHERE id > id_from AND state = 'colon' AND level = expression_level INTO id_end_variables_definition;
  	if id_end_variables_definition IS NULL then
	  call _throw_script_error(id_from, 'foreach: expected ":" as in (variables : collection)');
	end if;
	
    set id_from := id_from + 1;
	
	-- Expect variables declaration:
    call _expect_dynamic_states_list(id_from, id_end_variables_definition-1, 'query_script variable', variables_array_id);
	set variables_delaration_id := id_from;
	call _declare_local_variables(id_from, id_to, id_end_variables_definition, depth, variables_array_id);
		
    -- Get the collection clause:
	set id_from := id_end_variables_definition + 1;
    call _skip_spaces(id_from, id_to);

    call _expand_statement_variables(id_from, id_end_expression-1, collection, @_common_schema_dummy, should_execute_statement);
    -- SELECT GROUP_CONCAT(token ORDER BY id SEPARATOR '') FROM _sql_tokens WHERE id BETWEEN id_from AND id_end_expression-1 INTO collection;

    set consumed_to_id := id_end_expression;
end;
//

delimiter ;
