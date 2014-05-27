-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- Step into next breakpoint in current stack level or above (does not drill in).
--

DELIMITER $$

DROP procedure IF EXISTS _rdebug_set_step_hint $$
CREATE procedure _rdebug_set_step_hint(
  rdebug_hint_type varchar(32)
)
DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER

main_body: BEGIN
  declare rdebug_stack_level int unsigned default null;
  
  select
      ifnull(max(stack_level), 1)
    from _rdebug_stack_state
    where worker_id = @_rdebug_recipient_id
    group by worker_id
    into rdebug_stack_level;

  insert into 
      _rdebug_step_hints (worker_id, hint_type, stack_level, is_consumed)
    values 
      (@_rdebug_recipient_id, rdebug_hint_type, ifnull(rdebug_stack_level,1), 0)
    on duplicate key update 
      hint_type = values(hint_type), stack_level = values(stack_level), is_consumed = values(is_consumed) 
    ;
END $$

DELIMITER ;
