--
--
--

delimiter //

drop procedure if exists _consume_function_expression //

create procedure _consume_function_expression(
   in   id_from      int unsigned,
   in   id_to      int unsigned,
   out  consumed_to_id int unsigned,
   in   depth int unsigned,
   out  variables_array_id int unsigned,
   out  variables_declaration_id int unsigned,
   out	function_name text charset utf8,
   in should_execute_statement tinyint unsigned
)
comment 'Reads function ...() expression'
language SQL
deterministic
reads sql data
sql security invoker
main_body: begin
    declare first_state text;
    declare expression_level int unsigned;
    declare id_end_expression int unsigned default NULL;
    declare id_end_variables_definition int unsigned default NULL;
    declare count_functions tinyint unsigned default 0;

    call _skip_spaces(id_from, id_to);
    call _expect_state(id_from, id_from, 'alpha|alphanum', false, consumed_to_id, function_name);

    set id_from := id_from + 1;
    call _skip_spaces(id_from, id_to);
    set @_expression_level=null, @_first_state=null;
    SELECT level, state FROM _sql_tokens WHERE id = id_from INTO @_expression_level, @_first_state;
    set expression_level=@_expression_level;
    set first_state=@_first_state;
    if (first_state != 'left parenthesis') then
      call _throw_script_error(id_from, 'Expected "(" on function expression');
    end if;

    set @_id_end_expression=null;
    SELECT MIN(id) FROM _sql_tokens WHERE id > id_from AND state = 'right parenthesis' AND level = expression_level INTO @_id_end_expression;
    set id_end_expression=@_id_end_expression;
  	if id_end_expression IS NULL then
	  call _throw_script_error(id_from, 'Unmatched "(" parenthesis');
	end if;
	set id_end_variables_definition := id_end_expression;

    set id_from := id_from + 1;
	-- Do we have anything in parenthesis at all? Or empty function like "function f()"?
    call _skip_spaces(id_from, id_end_variables_definition);
	if id_from < id_end_variables_definition then
      -- Expect variables declaration:
      call _expect_dynamic_states_list(id_from, id_end_variables_definition-1, 'query_script variable', variables_array_id);
      -- And we do not actually declare the variables at this stage.
	  -- //LEGACY -- do not uncomment// call _declare_local_variables(id_from, id_to, id_end_variables_definition, depth, _implode_nospace_array(variables_array_id));
	end if;

	set variables_declaration_id := id_from;
    set consumed_to_id := id_end_expression;
end;
//

delimiter ;
