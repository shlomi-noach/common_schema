-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- Start debugging: attach to worker (recipient)
--

DELIMITER $$

DROP procedure IF EXISTS rdebug_start $$
CREATE procedure rdebug_start(
  recipient_id int unsigned
  )
DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER

BEGIN
  do get_lock(_rdebug_get_lock_name(connection_id(), 'debugger'), 0);
  if not get_lock(_rdebug_get_lock_name(recipient_id, 'worker'), 0) then
    do release_lock(_rdebug_get_lock_name(connection_id(), 'debugger'));
    call throw(CONCAT('Cannot obtain recipient lock for thread ', recipient_id));
  end if;
  set @_rdebug_recipient_id := recipient_id;
  set @_rdebug_worker_done := false;
  delete from _rdebug_routine_variables_state where worker_id = @_rdebug_recipient_id;
  delete from _rdebug_stack_state where worker_id = @_rdebug_recipient_id;
  -- delete from _rdebug_breakpoint_hints where worker_id = @_rdebug_recipient_id;
  delete from _rdebug_step_hints where worker_id = @_rdebug_recipient_id;
  delete from _rdebug_stats where worker_id = @_rdebug_recipient_id;
END $$

DELIMITER ;
