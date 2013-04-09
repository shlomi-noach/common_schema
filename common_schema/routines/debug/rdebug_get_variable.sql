-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- Return value of variable currently in active stack
-- 

DELIMITER $$

DROP function IF EXISTS rdebug_get_variable $$
CREATE function rdebug_get_variable(
    rdebug_variable_name varchar(128)
  ) returns blob
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER

main_body: BEGIN
  declare result blob default null;
  select 
      variable_value
    from 
      (select * from _rdebug_stack_state where worker_id = @_rdebug_recipient_id
       order by stack_level desc limit 1) select_current_stack_state
      join _rdebug_routine_variables using (routine_schema, routine_name)
      join _rdebug_routine_variables_state using (worker_id, stack_level, routine_schema, routine_name, variable_name)
    where
      statement_id between variable_scope_id_start and variable_scope_id_end
      and variable_name = rdebug_variable_name
    into result;
  return result;
END $$

DELIMITER ;
