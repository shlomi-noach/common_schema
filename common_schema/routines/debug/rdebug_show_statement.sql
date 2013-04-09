-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- Show statement at current breakpoint
-- 

DELIMITER $$

DROP procedure IF EXISTS rdebug_show_statement $$
CREATE procedure rdebug_show_statement()
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER

main_body: BEGIN
  declare rdebug_start_pos, rdebug_end_pos int unsigned default 0;
  declare rdebug_statement_id int unsigned;
  declare rdebug_routine_schema, rdebug_routine_name varchar(128) default null;
  declare debug_code_start varchar(64) charset utf8 default _rdebug_get_debug_code_start();
  declare debug_code_end varchar(64) charset utf8 default _rdebug_get_debug_code_end();
  declare rdebug_routine_body longblob default null;
  
  select 
      routine_schema, routine_name, statement_id, statement_start_pos, statement_end_pos
    from 
      (select * from _rdebug_stack_state where worker_id = @_rdebug_recipient_id
       order by stack_level desc limit 1) select_current_stack_state
      join _rdebug_routine_statements using (routine_schema, routine_name, statement_id)
    into
      rdebug_routine_schema, rdebug_routine_name, rdebug_statement_id, rdebug_start_pos, rdebug_end_pos
    ;
  select 
      body 
    from 
      mysql.proc 
    where 
      db = rdebug_routine_schema and name = rdebug_routine_name 
    into rdebug_routine_body;
  if rdebug_routine_body is null then
    leave main_body;
  end if;

  set rdebug_routine_body := replace_sections(rdebug_routine_body, debug_code_start, debug_code_end, '');
  select 
    rdebug_routine_schema as routine_schema, 
    rdebug_routine_name as routine_name,
    rdebug_statement_id as statement_id,
    substring(rdebug_routine_body, rdebug_start_pos, (rdebug_end_pos - rdebug_start_pos)) as `statement`
  ;
END $$

DELIMITER ;
