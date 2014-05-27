-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- Step into next breakpoint in current stack level or above (does not drill in).
--

DELIMITER $$

DROP procedure IF EXISTS rdebug_step_over $$
CREATE procedure rdebug_step_over()
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER

main_body: BEGIN
  call _rdebug_set_step_hint('step_over');
  -- call _rdebug_send_clock();

  -- call _rdebug_wait_for_breakpoint_clock();
  call _rdebug_release_worker_and_wait_for_breakpoint();
END $$

DELIMITER ;
