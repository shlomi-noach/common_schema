-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- Called upon breakpoint code
-- Does not necessarily mean the breakpoint should be active.
-- 

DELIMITER $$

DROP procedure IF EXISTS _rdebug_on_breakpoint 
$$
CREATE procedure _rdebug_on_breakpoint(
    in breakpoint_id int unsigned,
    in rdebug_routine_schema varchar(128) charset utf8,
    in rdebug_routine_name   varchar(128) charset utf8
  )
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER

main_body: BEGIN
  declare is_active_breakpoint bool default true;
  declare is_dedicated_breakpoint bool default true;
  declare rdebug_conditional_expression text default null;
  declare have_waited bool default false;

  select count(*) > 0 from _rdebug_step_hints 
    where worker_id = connection_id() 
    and (
      (hint_type = 'step_into')
      or (hint_type = 'step_over' and @_rdebug_stack_level_ <= stack_level)
      or (hint_type = 'step_out' and @_rdebug_stack_level_ < stack_level)
    )
    into is_active_breakpoint
  ;

  if not is_active_breakpoint then
    -- another chance: is there a dedicated breakpoint here?
    select count(statement_id) > 0, min(conditional_expression)
      from _rdebug_breakpoint_hints
      where 
        worker_id = connection_id()
        and routine_schema = rdebug_routine_schema
        and routine_name = rdebug_routine_name
        and statement_id = breakpoint_id
      into is_dedicated_breakpoint, rdebug_conditional_expression;
    if is_dedicated_breakpoint and rdebug_conditional_expression is null then
      -- explicit, non-conditional breakpoint here
      set is_active_breakpoint := true;
    end if;
  end if;

  if not is_active_breakpoint then
    leave main_body;
  end if;

  if is_used_lock(_rdebug_get_lock_name(connection_id(), 'tic')) then
    while is_used_lock(_rdebug_get_lock_name(connection_id(), 'tic')) != connection_id() do
      if not have_waited then
        call _rdebug_on_breakpoint_start_wait(breakpoint_id, rdebug_routine_schema, rdebug_routine_name);
      end if;
      do sleep(0.1 + coalesce(0, 'rdebug_worker_waiting_on_breakpoint'));
      set have_waited := true;
    end while;
  else
    while is_used_lock(_rdebug_get_lock_name(connection_id(), 'toc')) != connection_id() do
      if not have_waited then
        call _rdebug_on_breakpoint_start_wait(breakpoint_id, rdebug_routine_schema, rdebug_routine_name);
      end if;
      do sleep(0.1 + coalesce(0, 'rdebug_worker_waiting_on_breakpoint'));
      set have_waited := true;
    end while;
  end if;

  if have_waited then
    call _rdebug_on_breakpoint_end_wait(breakpoint_id, rdebug_routine_schema, rdebug_routine_name);
  end if;
END $$

DELIMITER ;
