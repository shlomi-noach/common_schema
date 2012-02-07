--
--
--

delimiter //

drop procedure if exists _declare_local_variables //

create procedure _declare_local_variables(
   in   id_from      int unsigned,
   in   id_to      int unsigned,
   in   statement_id_to      int unsigned,
   in   depth int unsigned,
   variables_array_id int unsigned
)
comment 'Declares local variables'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  declare num_variables int unsigned;
  declare variable_index int unsigned default 0;
  declare local_variable varchar(65) charset ascii;
  declare user_defined_variable_name varchar(65) charset ascii;
  declare declaration_is_new tinyint unsigned default 0;
  
  SELECT (COUNT(*) = 0) FROM _qs_variables WHERE declaration_id = id_from INTO declaration_is_new;
  if not declaration_is_new then
    -- Apparently there is a loop, since this id has already been visited and the variables in this id have already been declared.
    -- There is no need to do anything. The previous end-of-the-loop caused the mapped user defined variables to be reset to NULL. 
    leave main_body;
  end if;
  
  -- Start declaration
  call _get_array_size(variables_array_id, num_variables);
  set variable_index := 1;
  while variable_index <= num_variables do
    call _get_array_element(variables_array_id, variable_index, local_variable);
    set user_defined_variable_name := CONCAT('@__qs_local_var_', session_unique_id());

    INSERT IGNORE INTO _qs_variables (variable_name, mapped_user_defined_variable_name, declaration_depth, declaration_id) VALUES (local_variable, user_defined_variable_name, depth, id_from);
    if ROW_COUNT() = 0 then
      call _throw_script_error(id_from, CONCAT('Duplicate local variable: ', local_variable));
    end if;
    -- since the user defined variables are unique to this session, and have unlikely names they are expected to be NULL.
    -- Thusm we do not bother resetting them.

    -- Since this is first declaration point, we modify the _sql_tokens table by replacing variables with mapped user defined variables:
    UPDATE _sql_tokens SET token = user_defined_variable_name, state = 'user-defined variable' WHERE id > statement_id_to AND id <= id_to AND token = local_variable AND state = 'query_script variable';
    -- Bwahaha!
    
    set variable_index := variable_index + 1;
  end while;
end;
//

delimiter ;
