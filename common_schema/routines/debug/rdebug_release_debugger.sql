-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- Sent by the worker when entring a breakpoint wait 
--

DELIMITER $$

DROP procedure IF EXISTS rdebug_release_debugger $$
CREATE procedure rdebug_release_debugger()
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER

main_body: BEGIN
  call _rdebug_send_breakpoint_clock();
END $$

DELIMITER ;
