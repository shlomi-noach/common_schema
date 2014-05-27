-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- Extract variable names from a 'declare' statement.
-- The statement is assumed to declare variables (ass opposed to declare cursor, handler, state).
-- 

DELIMITER $$

DROP procedure IF EXISTS _rdebug_analyze_routine_declare_statement $$
CREATE procedure _rdebug_analyze_routine_declare_statement(
  in rdebug_routine_schema varchar(128) charset utf8,
  in rdebug_routine_name   varchar(128) charset utf8,
  in declare_id int unsigned,
  in declare_end_id int unsigned
)
DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT ''

main_body: BEGIN
  declare current_id int unsigned;
  declare current_token text charset utf8;
  declare current_state varchar(32);
  declare variable_expected tinyint unsigned default true;
  
  declare cursor_done tinyint unsigned default false;
  declare variables_cursor cursor for select id, token, state from _routine_tokens where id between declare_id + 1 and declare_end_id;
  declare continue handler for not found set cursor_done := true;

  open variables_cursor;
  cursor_loop: loop
    fetch variables_cursor into current_id, current_token, current_state; 
    if cursor_done then
      leave cursor_loop;
    end if;
    if current_state = 'whitespace' then
      iterate cursor_loop;
    end if;
    if current_state = 'comma' then
      set variable_expected := true;
      iterate cursor_loop;
    end if;
    if not variable_expected then
      leave cursor_loop;
    end if;
    
    insert ignore into 
      _rdebug_routine_variables (routine_schema, routine_name, variable_name, variable_scope_id_start, variable_scope_id_end, variable_type)
      values (rdebug_routine_schema, rdebug_routine_name, current_token, declare_id, NULL, 'local');
    set variable_expected := false;
  end loop;
  close variables_cursor;
END $$

DELIMITER ;
