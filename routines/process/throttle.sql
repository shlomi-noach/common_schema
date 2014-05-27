-- 
-- Throttle current query by periodically sleeping throughout its execution.
-- This function sleeps an amount of time proportional to the time the query executes,
-- on a per-lap basis. That is, time is measured between two invocations of this function,
-- and that time is multiplied by throttle_ratio to conclude the extent of throttling.
-- 

DELIMITER $$

DROP function IF EXISTS throttle $$
CREATE function throttle(throttle_ratio DOUBLE) returns DOUBLE
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT ''

begin
  set @_common_schema_throttle_counter := IFNULL(@_common_schema_throttle_counter, 0) + 1;
  -- Every 1000 rows - check for throttling.
  if @_common_schema_throttle_counter % 1000 = 0 then
    set @_common_schema_throttle_counter := 0;
    set @_common_schema_throttle_sysdate := SYSDATE();
    -- Make sure we're not examining values for a previous throttle()d query!
    -- NOW() is an indicator for this query.
    -- If previous throttle()d query also started at NOW(), well, there's no harm,
    -- since same second is considered to be insignificant.
    set @_common_schema_throttle_chunk_start := IFNULL(@_common_schema_throttle_chunk_start, NOW());
    set @_common_schema_throttle_chunk_start := GREATEST(@_common_schema_throttle_chunk_start, NOW());
    set @_common_schema_throttle_timediff := TIMESTAMPDIFF(SECOND, @_common_schema_throttle_chunk_start, @_common_schema_throttle_sysdate);
    set @_common_schema_throttle_sleep_time := @_common_schema_throttle_timediff * throttle_ratio;
    -- We do not necessarily throttle. Only if there has been at least a one second lapse.
    if @_common_schema_throttle_sleep_time > 0 then
      DO SLEEP(@_common_schema_throttle_sleep_time);
      set @_common_schema_throttle_chunk_start := SYSDATE();
      return @_common_schema_throttle_sleep_time;
    end if;
  end if;
  -- No throtling this time...
  return 0;
end $$

DELIMITER ;
