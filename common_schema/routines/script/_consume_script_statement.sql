--
--
--

delimiter //

drop procedure if exists _consume_script_statement //

create procedure _consume_script_statement(
   in   id_from      int unsigned,
   in   id_to      int unsigned,
   in   statement_id_from      int unsigned,
   in   statement_id_to      int unsigned,
   in   depth int unsigned,
   in   script_statement text charset utf8,
   in should_execute_statement tinyint unsigned
)
comment 'Reads script statement'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  declare tokens_array_id int unsigned;
  declare tokens_array_element text charset utf8;
  
  case script_statement
	when 'throttle' then begin
	    call _expect_states_list(statement_id_from, statement_id_to, 'integer|decimal', tokens_array_id);
		call _get_array_element(tokens_array_id, 1, tokens_array_element);
        if should_execute_statement then
          call _throttle_script(CAST(tokens_array_element AS DECIMAL));
        end if;
	  end;
    when 'throw' then begin
	    call _expect_states_list(statement_id_from, statement_id_to, 'string', tokens_array_id);
		call _get_array_element(tokens_array_id, 1, tokens_array_element);
        if should_execute_statement then
          call throw(tokens_array_element);
        end if;
	  end;
    when 'var' then begin
	    call _expect_dynamic_states_list(statement_id_from, statement_id_to, 'query_script variable', tokens_array_id);
		call _declare_local_variables(id_from, id_to, statement_id_to, depth, tokens_array_id);
	  end;
    when 'input' then begin
	    if @_common_schema_script_loop_nesting_level > 0 then
          call _throw_script_error(id_from, CONCAT('Invalid loop nesting level for INPUT: ', @_common_schema_script_loop_nesting_level));
	    end if;
	    call _expect_dynamic_states_list(statement_id_from, statement_id_to, 'query_script variable', tokens_array_id);
		call _declare_local_variables(id_from, id_to, statement_id_to, depth, tokens_array_id);
        if should_execute_statement then
          call _assign_input_local_variables(tokens_array_id);
        end if;
	  end;
    else begin 
	    -- Getting here is internal error
	    call _throw_script_error(id_from, CONCAT('Unknown script statement: "', script_statement, '"'));
	  end;
  end case;
  call _drop_array(tokens_array_id);
end;
//

delimiter ;
