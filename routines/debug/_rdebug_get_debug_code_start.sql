-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- 
-- 

DELIMITER $$

DROP FUNCTION IF EXISTS _rdebug_get_debug_code_start $$
CREATE FUNCTION _rdebug_get_debug_code_start() returns varchar(64) 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT ''

begin
  -- The reson the next text is broken is that we wish to avoid mistakenly identify this
  -- very routines as being a "with debug mode" due to the appearance of the magic
  -- start-code. Much like "ps aux | grep ... | grep -v grep"
  return CONCAT('/* [_common_schema_debug_', '] */');
end $$

DELIMITER ;
