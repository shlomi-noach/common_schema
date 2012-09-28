-- 
-- Summary of processlist states and their runtimes
-- 
CREATE OR REPLACE
ALGORITHM = UNDEFINED
SQL SECURITY INVOKER
VIEW processlist_states AS
  SELECT 
    STATE as state,
    COUNT(*) AS count_processes,
    CAST(split_token(GROUP_CONCAT(TIME ORDER BY TIME), ',', COUNT(*)/2) AS DECIMAL(10,2)) AS median_state_time,
    CAST(split_token(GROUP_CONCAT(TIME ORDER BY TIME), ',', COUNT(*)*95/100) AS DECIMAL(10,2)) AS median_95pct_state_time,
    MAX(TIME) AS max_state_time,
    SUM(TIME) AS sum_state_time
  FROM 
    INFORMATION_SCHEMA.PROCESSLIST 
  WHERE 
    id != CONNECTION_ID()
  GROUP BY
    STATE
  ORDER BY
    COUNT(*) DESC
;
