-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- Per variable, detect its scope end
-- 

DELIMITER $$

DROP procedure IF EXISTS _rdebug_analyze_routine_variables_scope $$
CREATE procedure _rdebug_analyze_routine_variables_scope(
  in rdebug_routine_schema varchar(128) charset utf8,
  in rdebug_routine_name   varchar(128) charset utf8
)
DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT ''

main_body: BEGIN
  declare current_variable_name varchar(128);
  declare current_variable_scope_id_start int unsigned;
  declare current_nesting_level int unsigned;
  declare scope_end_id int unsigned;
  
  declare cursor_done tinyint unsigned default false;
  declare variables_cursor cursor for 
    select variable_name, variable_scope_id_start, nesting_level
    from 
      _rdebug_routine_variables
      join _routine_tokens on (variable_scope_id_start = _routine_tokens.id)
    where routine_schema = rdebug_routine_schema and routine_name = rdebug_routine_name and variable_type = 'local';
  declare continue handler for not found set cursor_done := true;

  open variables_cursor;
  cursor_loop: loop
    fetch variables_cursor into current_variable_name, current_variable_scope_id_start, current_nesting_level; 
    if cursor_done then
      leave cursor_loop;
    end if;
    -- Find end of block for current variable (by finding first time nesting level is smaller than current)
    select min(id) - 1 
      from _routine_tokens
      where id >= current_variable_scope_id_start and nesting_level < current_nesting_level
      into scope_end_id;

    update _rdebug_routine_variables set variable_scope_id_end = scope_end_id 
      where 
        routine_schema = rdebug_routine_schema 
        and routine_name = rdebug_routine_name 
        and variable_name = current_variable_name 
        and variable_scope_id_start = current_variable_scope_id_start;
  end loop;
  close variables_cursor;
  
  select max(id) from _routine_tokens into scope_end_id;
  update _rdebug_routine_variables set variable_scope_id_end = scope_end_id 
    where routine_schema = rdebug_routine_schema and routine_name = rdebug_routine_name and variable_type in ('user_defined', 'param');
END $$

DELIMITER ;
