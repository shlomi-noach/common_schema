-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- Called upon an active breakpoint, just as the worker starts waiting.
-- This method is only called once per breakpoint entry. 
--
 
DELIMITER $$

DROP procedure IF EXISTS _rdebug_on_breakpoint_start_wait $$
CREATE procedure _rdebug_on_breakpoint_start_wait(
    in breakpoint_id int unsigned,
    in rdebug_routine_schema varchar(128) charset utf8,
    in rdebug_routine_name   varchar(128) charset utf8
  )
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER

main_body: BEGIN
  delete from _rdebug_stack_state 
    where worker_id = connection_id() and stack_level > @_rdebug_stack_level_;
  delete from _rdebug_routine_variables_state 
    where worker_id = connection_id() and stack_level > @_rdebug_stack_level_;
    
  insert into _rdebug_stack_state 
      (worker_id, stack_level, routine_schema, routine_name, statement_id) 
    values 
      (connection_id(), @_rdebug_stack_level_, rdebug_routine_schema, rdebug_routine_name, breakpoint_id)
    on duplicate key update 
      routine_schema = VALUES(routine_schema),
      routine_name = VALUES(routine_name),
      statement_id = VALUES(statement_id);
  
  call _rdebug_export_variable_state(breakpoint_id, rdebug_routine_schema, rdebug_routine_name);

  call _rdebug_send_breakpoint_clock();
END $$

DELIMITER ;
