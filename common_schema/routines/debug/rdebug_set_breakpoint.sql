-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- Set/clear a breakpoint
-- 

DELIMITER $$

DROP procedure IF EXISTS rdebug_set_breakpoint $$
CREATE procedure rdebug_set_breakpoint(
    in rdebug_routine_schema varchar(128) charset utf8,
    in rdebug_routine_name   varchar(128) charset utf8,
    in rdebug_statement_id   int unsigned,
    in rdebug_conditional_expression text charset utf8,
    in breakpoint_enabled bool
  )
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER

main_body: BEGIN
  if breakpoint_enabled then
    insert into 
      _rdebug_breakpoint_hints (worker_id, routine_schema, routine_name, statement_id, conditional_expression)
      values (@_rdebug_recipient_id, rdebug_routine_schema, rdebug_routine_name, rdebug_statement_id, rdebug_conditional_expression)
      on duplicate key update conditional_expression = values(conditional_expression)
    ;
  else
    delete from _rdebug_breakpoint_hints
      where worker_id = @_rdebug_recipient_id
        and routine_schema = rdebug_routine_schema
        and routine_name = rdebug_routine_name
        and statement_id = rdebug_statement_id
    ;
  end if;
END $$

DELIMITER ;
