-- 
-- Do not invoke twice within the same script 
--
DELIMITER $$

DROP procedure IF EXISTS _throttle_script $$
CREATE procedure _throttle_script(throttle_ratio DOUBLE)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT ''

begin
  set @_common_schema_script_throttle_sysdate := SYSDATE();
  -- _interpret() resets @_common_schema_script_throttle_chunk_start to NULL per script.
  set @_common_schema_script_throttle_chunk_start := IFNULL(@_common_schema_script_throttle_chunk_start, @_common_schema_script_start_timestamp);
  set @_common_schema_script_throttle_timediff := TIMESTAMPDIFF(SECOND, @_common_schema_script_throttle_chunk_start, @_common_schema_script_throttle_sysdate);
  set @_common_schema_script_throttle_sleep_time := @_common_schema_script_throttle_timediff * throttle_ratio;
  -- We do not necessarily throttle. Only if there has been at least a one second lapse.
  if @_common_schema_script_throttle_sleep_time > 0 then
    DO SLEEP(@_common_schema_script_throttle_sleep_time);
    set @_common_schema_script_throttle_chunk_start := SYSDATE();
  end if;
end $$

DELIMITER ;
