-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- Sent by the worker when entring a breakpoint wait 
--

DELIMITER $$

DROP procedure IF EXISTS _rdebug_send_breakpoint_clock $$
CREATE procedure _rdebug_send_breakpoint_clock()
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER

main_body: BEGIN
  call thread_notify(concat('breakpoint_clock_', connection_id()));
  leave main_body;
  
  select 
    if(
      is_used_lock(_rdebug_get_lock_name(connection_id(), 'breakpoint_tic')) = connection_id(),
      release_lock(_rdebug_get_lock_name(connection_id(), 'breakpoint_tic')) + get_lock(_rdebug_get_lock_name(connection_id(), 'breakpoint_toc'), 100000000),
      release_lock(_rdebug_get_lock_name(connection_id(), 'breakpoint_toc')) + get_lock(_rdebug_get_lock_name(connection_id(), 'breakpoint_tic'), 100000000)
    )
  into @common_schema_dummy;
END $$

DELIMITER ;
