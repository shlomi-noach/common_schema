--
--
--

delimiter //

drop procedure if exists _declare_local_variable //

create procedure _declare_local_variable(
   in   id_variable_declaration      int unsigned,
   in   id_from    int unsigned,
   in   id_to      int unsigned,
   in   depth int unsigned,
   in	local_variable varchar(65) charset ascii,
   in	user_defined_variable_name varchar(65) charset ascii,
   in	throw_when_exists tinyint unsigned
)
comment 'Declare a local variable'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  INSERT IGNORE INTO _qs_variables (variable_name, mapped_user_defined_variable_name, declaration_depth, declaration_id) VALUES (local_variable, user_defined_variable_name, depth, id_variable_declaration);
  if ROW_COUNT() = 0 and throw_when_exists then
    call _throw_script_error(id_from, CONCAT('Duplicate local variable: ', local_variable));
  end if;
  -- since the user defined variables are unique to this session, and have unlikely names they are expected to be NULL.
  -- Thus, we do not bother resetting them.

  -- Since this is first declaration point, we modify the _sql_tokens table by replacing variables with mapped user defined variables:
  UPDATE _sql_tokens SET token = user_defined_variable_name, state = 'user-defined variable' WHERE id > id_from AND id <= id_to AND token = local_variable AND state = 'query_script variable';
  -- Bwahaha!
end;
//

delimiter ;
