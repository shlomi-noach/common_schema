-- 
-- Return "lap-time" for current query: time elapsed since last invocation of this function
-- in current query.
-- Essentially, this function allows for measurement of time elapsed between invocations.
--

DELIMITER $$

DROP FUNCTION IF EXISTS query_laptime $$
CREATE FUNCTION query_laptime() RETURNS DOUBLE 
DETERMINISTIC
NO SQL
SQL SECURITY INVOKER
COMMENT 'Return current query runtime'

begin
  declare time_right_now TIMESTAMP;
  declare query_time_now TIMESTAMP;
  declare time_diff DOUBLE;
  
  set time_right_now := SYSDATE();	
  set query_time_now := NOW();	
  -- Make sure we're not examining values for a previous query_laptime() execution!
  -- NOW() is an indicator for this query.
  -- If previous query_laptime() query also started at NOW(), well, there's no harm,
  -- since same second is considered to be insignificant.
  if @_common_schema_laptime_lap_start is null then
    set @_common_schema_laptime_lap_start := query_time_now;
  else
    set @_common_schema_laptime_lap_start := GREATEST(@_common_schema_laptime_lap_start, query_time_now);
  end if;
  set time_diff := TIMESTAMPDIFF(MICROSECOND, @_common_schema_laptime_lap_start, time_right_now) / 1000000.0;
  set @_common_schema_laptime_lap_start := time_right_now;
  
  return time_diff;
end $$
