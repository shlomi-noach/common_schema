-- 
-- This code is free software; you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, version 2
--
-- 
-- 

DELIMITER $$

DROP procedure IF EXISTS _rdebug_send_clock $$
CREATE procedure _rdebug_send_clock()
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER

BEGIN
  select 
    if(
      is_used_lock(_rdebug_get_lock_name(@_rdebug_recipient_id, 'tic')) = connection_id(),
      release_lock(_rdebug_get_lock_name(@_rdebug_recipient_id, 'tic')) + get_lock(_rdebug_get_lock_name(@_rdebug_recipient_id, 'toc'), 100000000),
      release_lock(_rdebug_get_lock_name(@_rdebug_recipient_id, 'toc')) + get_lock(_rdebug_get_lock_name(@_rdebug_recipient_id, 'tic'), 100000000)
    )
  into @common_schema_dummy;
END $$

DELIMITER ;
