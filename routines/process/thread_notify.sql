-- 
-- 
-- 

DELIMITER $$

DROP procedure IF EXISTS thread_notify $$
CREATE procedure thread_notify(
    in thread_wait_name varchar(128) character set ascii)
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT ''

begin
  insert 
    into _waits (wait_name, wait_value)
    values (thread_wait_name, 1)
    on duplicate key update wait_value = wait_value + 1, last_entry_time = NOW()
  ;
end $$

DELIMITER ;
