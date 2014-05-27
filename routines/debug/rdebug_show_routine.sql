-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- 

DELIMITER $$

DROP procedure IF EXISTS rdebug_show_routine $$
CREATE procedure rdebug_show_routine(
  in rdebug_routine_schema varchar(128) charset utf8,
  in rdebug_routine_name   varchar(128) charset utf8
  )
DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT ''

BEGIN
  declare routine_body longblob default null;
  declare debug_code_start varchar(64) charset utf8 default _rdebug_get_debug_code_start();
  declare debug_code_end varchar(64) charset utf8 default _rdebug_get_debug_code_end();

  select body from mysql.proc where db = rdebug_routine_schema and name = rdebug_routine_name into routine_body;
  if routine_body is null then
    call throw(CONCAT('Unknown routine: ', mysql_qualify(rdebug_routine_schema), '.', mysql_qualify(rdebug_routine_name)));
  end if;
  
  set routine_body := replace_sections(routine_body, concat(debug_code_start, _rdebug_get_debug_code_breakpoint_hint_start()), _rdebug_get_debug_code_breakpoint_hint_end(), concat('[:\\0]', debug_code_start));
  set routine_body := replace_sections(routine_body, concat(debug_code_start, _rdebug_get_debug_code_breakpoint_hint()), debug_code_end, '[:]');
  set routine_body := replace_sections(routine_body, debug_code_start, debug_code_end, '');
  call prettify_message(concat(mysql_qualify(rdebug_routine_schema), '.', mysql_qualify(rdebug_routine_name), ' breakpoints'), routine_body);
END $$

DELIMITER ;
