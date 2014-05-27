-- 
-- 
-- 

DELIMITER $$

DROP procedure IF EXISTS thread_wait $$
CREATE procedure thread_wait(
    in thread_wait_name varchar(128) character set ascii, 
    in poll_seconds double,
    in atomic_execute_query text charset utf8,
    in alternate_end_wait_condition text charset utf8)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT ''

begin
  declare current_wait_value bigint unsigned;
  
  if alternate_end_wait_condition is not null then
  	set alternate_end_wait_condition := concat('select (', alternate_end_wait_condition, ') is true into @common_schema_thread_wait_end_condition');
  end if;
  
  select 
      ifnull(max(wait_value), 0) 
    from _waits 
    where wait_name = thread_wait_name 
    into current_wait_value;
  commit;
  
  if atomic_execute_query is not null then
  	call exec_single(atomic_execute_query);
  end if;
  
  set @common_schema_thread_wait_end_condition := false;
  wait_loop: while (select ifnull(max(wait_value), 0) <= current_wait_value from _waits where wait_name = thread_wait_name) do
    if alternate_end_wait_condition is not null then
      call exec_single(alternate_end_wait_condition);
      if @common_schema_thread_wait_end_condition then
        leave wait_loop;
      end if;
    end if;  
    do sleep(poll_seconds + coalesce(0, 'common_schema_thread_wait'));
    commit;
  end while;
end $$

DELIMITER ;
