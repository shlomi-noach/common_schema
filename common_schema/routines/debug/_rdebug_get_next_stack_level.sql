-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- Executed by the worker
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS _rdebug_get_next_stack_level $$
CREATE FUNCTION _rdebug_get_next_stack_level() returns int unsigned 
DETERMINISTIC
READS SQL DATA
SQL SECURITY DEFINER
COMMENT 'Return next in order stack level'

begin
  declare next_stack_level int unsigned default null;
  
  select 
      max(stack_level) 
    from 
      _rdebug_stack_state
    where
      worker_id = CONNECTION_ID()
    into next_stack_level;
  
  if next_stack_level is null
    then return 1;
  end if;
  return IFNULL(@_rdebug_stack_level_ + 1, 1);
end $$

DELIMITER ;
