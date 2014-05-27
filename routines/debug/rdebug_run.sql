-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- Step into next breakpoint in current stack level or above (does not drill in).
--

DELIMITER $$

DROP procedure IF EXISTS rdebug_run $$
CREATE procedure rdebug_run()
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER

main_body: BEGIN
  call _rdebug_set_step_hint('run');
  -- call _rdebug_send_clock();

  -- call _rdebug_wait_for_breakpoint_clock();
  call _rdebug_release_worker_and_wait_for_breakpoint();
END $$

DELIMITER ;
