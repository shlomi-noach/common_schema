-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- 
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS _rdebug_get_debug_code_breakpoint_hint_end $$
CREATE FUNCTION _rdebug_get_debug_code_breakpoint_hint_end() returns varchar(64) 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT ''

begin
  return ':]*/';
end $$

DELIMITER ;
