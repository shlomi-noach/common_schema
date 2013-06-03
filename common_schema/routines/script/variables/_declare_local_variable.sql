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
  -- select *, 'existing',id_variable_declaration from _qs_variables WHERE variable_name = local_variable;
  delete from _qs_variables WHERE variable_name = local_variable and ((scope_end_id < id_variable_declaration) or (declaration_id >= id_variable_declaration));

  -- declare overlapping_variable_exists tinyint unsigned;	
  -- select (count(*) > 0) from _qs_variables where variable_name = local_variable and id_variable_declaration between declaration_id and scope_end_id into overlapping_variable_exists;
  -- if overlapping_variable_exists and throw_when_exists then
  --   call _throw_script_error(id_from, CONCAT('Duplicate local variable: ', local_variable));
  -- end if;
   
  INSERT IGNORE INTO _qs_variables (session_id, variable_name, mapped_user_defined_variable_name, declaration_depth, declaration_id, scope_end_id) 
    VALUES (CONNECTION_ID(), local_variable, user_defined_variable_name, depth, id_variable_declaration, id_to);
  if ROW_COUNT() = 0 and throw_when_exists then
    call _throw_script_error(id_variable_declaration, CONCAT('Duplicate local variable: ', local_variable));
  end if;
  -- since the user defined variables are unique to this session, and have unlikely names they are expected to be NULL.
  -- Thus, we do not bother resetting them.

  -- Since this is first declaration point, we modify the _sql_tokens table by replacing variables with mapped user defined variables:
  -- UPDATE _sql_tokens SET token = user_defined_variable_name, state = 'user-defined variable' WHERE id > id_from AND id <= id_to AND token = local_variable AND state = 'query_script variable';
  -- Bwahaha!
end;
//

delimiter ;
