-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- 
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS _rdebug_get_lock_name $$
CREATE FUNCTION _rdebug_get_lock_name(
  connection_id int unsigned,
  name_hint varchar(32)
  ) returns varchar(64) 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Return value of option in JS options format'

begin
  return CONCAT_WS('_', '__common_schema_rdebug_lock', connection_id, name_hint);
end $$

DELIMITER ;
