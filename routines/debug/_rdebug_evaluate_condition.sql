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

DROP procedure IF EXISTS _rdebug_evaluate_condition $$
CREATE procedure _rdebug_evaluate_condition(
    in  rdebug_condition text,
    out rdebug_condition_result bool
  )
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER

main_body: begin
  if rdebug_condition is null or rdebug_condition = '' then
    set rdebug_condition_result := true;
    leave main_body;
  end if;
  select 
      concat('
        select (', rdebug_condition, ') is true into @_common_schema_rdebug_condition_result'
      )
    into @_rdebug_command
  ;

  prepare st from @_rdebug_command;
  execute st;
  deallocate prepare st;

  set rdebug_condition_result := @_common_schema_rdebug_condition_result;
END $$

DELIMITER ;
