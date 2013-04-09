-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- Show statement IDs for a given routine
-- 

DELIMITER $$

DROP procedure IF EXISTS rdebug_show_routine_statements $$
CREATE procedure rdebug_show_routine_statements(
  in rdebug_routine_schema varchar(128) charset utf8,
  in rdebug_routine_name   varchar(128) charset utf8
  )
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER

main_body: BEGIN
  select 
      routine_schema, routine_name, statement_id
    from 
      _rdebug_routine_statements 
    where 
      routine_schema = rdebug_routine_schema
      and routine_name = rdebug_routine_name
    order by statement_id
  ;
END $$

DELIMITER ;
