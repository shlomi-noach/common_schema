-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- Currently unused!
--

DELIMITER $$

DROP procedure IF EXISTS _rdebug_wait_for_breakpoint_clock $$
CREATE procedure _rdebug_wait_for_breakpoint_clock()
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER

main_body: BEGIN
  declare have_waited bool default false;

  -- In case no breakpoint lock is taken (e.g. the worker hasn't started execution yet)
  -- then wait for one lock to appear then exit.
  while is_used_lock(_rdebug_get_lock_name(@_rdebug_recipient_id, 'breakpoint_tic')) is null
    and is_used_lock(_rdebug_get_lock_name(@_rdebug_recipient_id, 'breakpoint_toc')) is null do 
      do sleep(0.1);
      set have_waited := true;
  end while;
  if have_waited then
    leave main_body;
  end if;
  
  -- apparently one lock is taken. Wait!
  if is_used_lock(_rdebug_get_lock_name(@_rdebug_recipient_id, 'breakpoint_tic')) then
    while is_used_lock(_rdebug_get_lock_name(@_rdebug_recipient_id, 'breakpoint_tic')) = @_rdebug_recipient_id do
      do sleep(0.1);
    end while;
  else
    while is_used_lock(_rdebug_get_lock_name(@_rdebug_recipient_id, 'breakpoint_toc')) = @_rdebug_recipient_id do
      do sleep(0.1);
    end while;
  end if;
END $$

DELIMITER ;
