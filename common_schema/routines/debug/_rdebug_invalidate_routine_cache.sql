-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- 
-- 

DELIMITER $$

DROP procedure IF EXISTS _rdebug_invalidate_routine_cache $$
CREATE procedure _rdebug_invalidate_routine_cache()
DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY DEFINER

BEGIN
  create or replace view _rdebug_invalidate_routine_cache_view as select 1 as `invalidated`;
END $$

DELIMITER ;
