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

DROP procedure IF EXISTS _rdebug_on_breakpoint_end_wait $$
CREATE procedure _rdebug_on_breakpoint_end_wait(
    in breakpoint_id int unsigned,
    in rdebug_routine_schema varchar(128) charset utf8,
    in rdebug_routine_name   varchar(128) charset utf8
  )
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER

main_body: BEGIN
  call _rdebug_import_variable_state(breakpoint_id, rdebug_routine_schema, rdebug_routine_name);
  -- do release_lock(_rdebug_get_lock_name(connection_id(), 'breakpoint'));
END $$

DELIMITER ;
