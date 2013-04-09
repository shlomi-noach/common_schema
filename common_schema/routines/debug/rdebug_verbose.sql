-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- Step into next breakpoint in current stack level or above (does not drill in).
--

DELIMITER $$

DROP procedure IF EXISTS rdebug_verbose $$
CREATE procedure rdebug_verbose()
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER

main_body: BEGIN
  call rdebug_show_stack_state();
  call rdebug_watch_variables();
  call rdebug_show_statement();
END $$

DELIMITER ;
