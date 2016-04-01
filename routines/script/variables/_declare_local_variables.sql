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
   imploded_variables TEXT
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

  SELECT
      (COUNT(*) = 0)
    FROM
      _qs_variables
    WHERE
      declaration_id = id_from
      and (function_scope = _get_current_variables_function_scope())
    INTO 
      @_declaration_is_new;
  set declaration_is_new=@_declaration_is_new;
  if not declaration_is_new then
    -- Apparently there is a loop, since this id has already been visited and the variables in this id have already been declared.
    -- There is no need to do anything. The previous end-of-the-loop caused the mapped user defined variables to be reset to NULL.
    leave main_body;
  end if;

  -- Start declaration
  set num_variables := get_num_tokens(imploded_variables, ',');
  set variable_index := 1;
  while variable_index <= num_variables do
    set local_variable := split_token(imploded_variables, ',', variable_index);
    set user_defined_variable_name := CONCAT('@__qs_local_var_', session_unique_id());

    call _declare_local_variable(id_from, statement_id_to, id_to, depth, local_variable, user_defined_variable_name, TRUE);

    set variable_index := variable_index + 1;
  end while;
end;
//

delimiter ;
