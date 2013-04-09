-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- 

DELIMITER $$

DROP procedure IF EXISTS _rdebug_release_worker_and_wait_for_breakpoint $$
CREATE procedure _rdebug_release_worker_and_wait_for_breakpoint()
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER

BEGIN
  call thread_wait(
    concat('breakpoint_clock_', @_rdebug_recipient_id), 
    0.1, 
    'call _rdebug_send_clock()', 
    concat('
       (select ifnull(max(command)=''Sleep'', true) from information_schema.processlist where id=', @_rdebug_recipient_id, ')
       and (select count(*) > 0 from _rdebug_stack_state where worker_id=',@_rdebug_recipient_id, ')
    ')
  );
  select ifnull(max(command)='Sleep', true) from information_schema.processlist where id=@_rdebug_recipient_id into @_rdebug_worker_done;
  if @_rdebug_worker_done then
    -- Identify the case where the worker has actually quit (last routine exited)
    delete from _rdebug_stack_state where worker_id = @_rdebug_recipient_id;
  end if;
  if @_rdebug_verbose and not @_rdebug_worker_done then
    call rdebug_verbose();
  end if;
END $$

DELIMITER ;
