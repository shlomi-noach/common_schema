-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- Write down current variable (variables within current scope)
-- into global variables state table
-- 

DELIMITER $$

DROP procedure IF EXISTS _rdebug_export_variable_state $$
CREATE procedure _rdebug_export_variable_state(
    in breakpoint_id int unsigned,
    in rdebug_routine_schema varchar(128) charset utf8,
    in rdebug_routine_name   varchar(128) charset utf8
  )
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER

BEGIN
  select 
      concat('
        insert into _rdebug_routine_variables_state
          (worker_id, stack_level, routine_schema, routine_name, variable_name, variable_value)
        values
        ', 
          group_concat(
            '(CONNECTION_ID(), @_rdebug_stack_level_, ', QUOTE(rdebug_routine_schema), ',', QUOTE(rdebug_routine_name),
            ',', QUOTE(variable_name), ',', IF(variable_type IN ('param', 'local'), CONCAT('@$_$', variable_name), variable_name), ')'
           ),
        ' on duplicate key update variable_value=VALUES(variable_value)'
      )
    from
      _rdebug_routine_variables 
    where
      breakpoint_id between _rdebug_routine_variables.variable_scope_id_start and _rdebug_routine_variables.variable_scope_id_end
      and routine_schema = rdebug_routine_schema and routine_name = rdebug_routine_name
    into @_rdebug_command
  ;
  if @_rdebug_command is not null then
    -- Could be NULL when _rdebug_routine_variables has nothing for us
    prepare st from @_rdebug_command;
    execute st;
    deallocate prepare st;
  end if;
END $$

DELIMITER ;
