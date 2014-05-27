-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- Start debugging: attach to worker (recipient)
--

DELIMITER $$

DROP procedure IF EXISTS rdebug_set_verbose $$
CREATE procedure rdebug_set_verbose(
    in verbose bool
  )
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER

BEGIN
  set @_rdebug_verbose := (verbose is true);
END $$

DELIMITER ;
