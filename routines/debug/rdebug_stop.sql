-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- Clear debugging data, remove all locks.
--

DELIMITER $$

DROP procedure IF EXISTS rdebug_stop $$
CREATE procedure rdebug_stop()
DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER

main_body: BEGIN
  do release_lock(_rdebug_get_lock_name(connection_id(), 'debugger'));
  if @_rdebug_recipient_id is null then
    leave main_body;
  end if;
  do release_lock(_rdebug_get_lock_name(@_rdebug_recipient_id, 'worker'));
  do release_lock(_rdebug_get_lock_name(@_rdebug_recipient_id, 'tic'));
  do release_lock(_rdebug_get_lock_name(@_rdebug_recipient_id, 'toc'));

  delete from _rdebug_routine_variables_state where worker_id = @_rdebug_recipient_id;
  delete from _rdebug_stack_state where worker_id = @_rdebug_recipient_id;
  delete from _rdebug_breakpoint_hints where worker_id = @_rdebug_recipient_id;
  delete from _rdebug_step_hints where worker_id = @_rdebug_recipient_id;
  delete from _rdebug_stats where worker_id = @_rdebug_recipient_id;
  
  set @_rdebug_recipient_id := null;
END $$

DELIMITER ;
