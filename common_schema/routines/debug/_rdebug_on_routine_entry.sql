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

DROP procedure IF EXISTS _rdebug_on_routine_entry 
$$
CREATE procedure _rdebug_on_routine_entry(
    in rdebug_routine_schema varchar(128) charset utf8,
    in rdebug_routine_name   varchar(128) charset utf8
  )
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER

main_body: BEGIN	
  if is_used_lock(_rdebug_get_lock_name(connection_id(), 'worker')) is null then
    leave main_body;
  end if;

  insert into _rdebug_stats (
    worker_id, routine_schema, routine_name, statement_id, count_visits)
    values (connection_id(), rdebug_routine_schema, rdebug_routine_name, 0, 1)
    on duplicate key update count_visits = count_visits + 1;
END $$

DELIMITER ;
