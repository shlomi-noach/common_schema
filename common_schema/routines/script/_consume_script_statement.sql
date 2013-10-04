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
  declare matched_token text charset utf8;
  declare statement_arguments text charset utf8;
  declare expanded_variables_found tinyint unsigned;
  
  call _expand_statement_variables(id_from+1, statement_id_to, statement_arguments, expanded_variables_found, should_execute_statement);
  
  set tokens_array_id := NULL;
  
  case script_statement
	when 'start' then begin
	    call _expect_token(statement_id_from, statement_id_to, 'transaction', false, @_common_schema_dummy, @_common_schema_dummy);
        if should_execute_statement then
          start transaction;
        end if;
	  end;
	when 'begin' then begin
		call _expect_nothing(statement_id_from, statement_id_to);
        if should_execute_statement then
          start transaction;
        end if;
	  end;
	when 'commit' then begin
		call _expect_nothing(statement_id_from, statement_id_to);
        if should_execute_statement then
          commit;
        end if;
	  end;
	when 'rollback' then begin
		call _expect_nothing(statement_id_from, statement_id_to);
        if should_execute_statement then
          rollback;
        end if;
	  end;
	when 'echo' then begin
        if should_execute_statement then
          select trim_wspace(statement_arguments) as echo;
        end if;
	  end;
	when 'eval' then begin
        if should_execute_statement then
          call eval(statement_arguments);
        end if;
	  end;
	when 'invoke' then begin
		call _consume_function_call_statement(id_from, statement_id_from, statement_id_to, depth, should_execute_statement);
	  end;
	when 'pass' then begin
	    call _expect_nothing(statement_id_from, statement_id_to);
	  end;
	when 'sleep' then begin
	    call _expect_state(statement_id_from, statement_id_to, 'integer|decimal|user-defined variable|query_script variable', false, @_common_schema_dummy, matched_token);
	    -- Now that states list is validated, we just take the statement argument (there's only 1) for benefit of variable expansion:
        if should_execute_statement then
          call exec(CONCAT('SET @_common_schema_intermediate_var := ', statement_arguments));
          DO SLEEP(CAST(trim_wspace(@_common_schema_intermediate_var) AS DECIMAL(64, 2)));
        end if;
	  end;
	when 'throttle' then begin
	    call _expect_state(statement_id_from, statement_id_to, 'integer|decimal|user-defined variable|query_script variable', false, @_common_schema_dummy, matched_token);
	    -- Now that states list is validated, we just take the statement argument (there's only 1) for benefit of variable expansion:
        if should_execute_statement then
          call exec(CONCAT('SET @_common_schema_intermediate_var := ', statement_arguments));
          call _throttle_script(CAST(trim_wspace(@_common_schema_intermediate_var) AS DECIMAL(64, 2)));
        end if;
	  end;
    when 'throw' then begin
	    call _expect_state(statement_id_from, statement_id_to, 'string|user-defined variable|query_script variable', false, @_common_schema_dummy, matched_token);
        if should_execute_statement then
          call exec(CONCAT('SET @_common_schema_intermediate_var := ', statement_arguments));
          call throw(@_common_schema_intermediate_var);
        end if;
	  end;
    when 'var' then begin
	    call _peek_states_list(statement_id_from, statement_id_to, 'query_script variable,assign', true, true, false, @_common_schema_dummy, @_common_schema_peek_to_id);
	    if @_common_schema_peek_to_id > 0 then
	      -- a delare-and-assign statement, e.g. var $x := 3;
	      call _declare_and_assign_local_variable(id_from, id_to, statement_id_from, @_common_schema_peek_to_id, statement_id_to, depth, should_execute_statement);
	    else
          call _expect_dynamic_states_list(statement_id_from, statement_id_to, 'query_script variable', tokens_array_id);
          call _declare_local_variables(id_from, id_to, statement_id_to, depth, _implode_nospace_array(tokens_array_id));
	    end if;
	  end;
    when 'input' then begin
	    if @_common_schema_script_loop_nesting_level > 0 then
          call _throw_script_error(id_from, CONCAT('Invalid loop nesting level for INPUT: ', @_common_schema_script_loop_nesting_level));
	    end if;
	    call _expect_dynamic_states_list(statement_id_from, statement_id_to, 'query_script variable', tokens_array_id);
		call _declare_local_variables(id_from, id_to, statement_id_to, depth, _implode_nospace_array(tokens_array_id));
        if should_execute_statement then
          call _assign_input_local_variables(tokens_array_id);
        end if;
	  end;
	when 'report' then begin
        if should_execute_statement then
          call _script_report(statement_arguments);
        end if;
	  end;
    else begin 
	    -- Getting here is internal error
	    call _throw_script_error(id_from, CONCAT('Unknown script statement: "', script_statement, '"'));
	  end;
  end case;
  if tokens_array_id is not null then
    call _drop_array(tokens_array_id);
  end if;
end;
//

delimiter ;
