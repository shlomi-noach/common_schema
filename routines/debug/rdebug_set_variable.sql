-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- Modify value of variable in active stack
-- 

DELIMITER $$

DROP procedure IF EXISTS rdebug_set_variable $$
CREATE procedure rdebug_set_variable(
    in rdebug_variable_name varchar(128),
    in rdebug_variable_value blob
  )
DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER

main_body: BEGIN
  declare current_stack_level int unsigned;
  
  select 
      max(stack_level) 
    from 
      _rdebug_stack_state 
    where 
      worker_id = @_rdebug_recipient_id
    into current_stack_level;
    
  update 
      _rdebug_stack_state
      join _rdebug_routine_variables using (routine_schema, routine_name)
      join _rdebug_routine_variables_state using (worker_id, stack_level, routine_schema, routine_name, variable_name)
    set 
      variable_value = rdebug_variable_value
    where
      _rdebug_stack_state.worker_id = @_rdebug_recipient_id
      and _rdebug_stack_state.stack_level = current_stack_level
      and _rdebug_stack_state.statement_id between variable_scope_id_start and variable_scope_id_end
      and variable_name = rdebug_variable_name
      ;
END $$

DELIMITER ;
