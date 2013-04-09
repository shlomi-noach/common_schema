-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- Show visible variables in active stack
-- 

DELIMITER $$

DROP procedure IF EXISTS rdebug_show_stack_state $$
CREATE procedure rdebug_show_stack_state()
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER

main_body: BEGIN
  select 
      stack_level, routine_schema, routine_name, statement_id, entry_time
    from 
      _rdebug_stack_state 
    where 
      worker_id = @_rdebug_recipient_id
    order by stack_level
  ;
END $$

DELIMITER ;
