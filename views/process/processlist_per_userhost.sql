-- 
-- State of processes per user/host: connected, executing, average execution time
-- 
CREATE OR REPLACE
ALGORITHM = UNDEFINED
SQL SECURITY INVOKER
VIEW processlist_per_userhost AS
  SELECT 
    USER AS user,
    MIN(SUBSTRING_INDEX(HOST, ':', 1)) AS host,
    COUNT(*) AS count_processes,
    SUM(COMMAND != 'Sleep') AS active_processes,
    CAST(split_token(GROUP_CONCAT(IF(COMMAND != 'Sleep', TIME, NULL) ORDER BY TIME), ',', COUNT(IF(COMMAND != 'Sleep', TIME, NULL))/2) AS DECIMAL(10,2)) AS median_active_time,
    CAST(split_token(GROUP_CONCAT(IF(COMMAND != 'Sleep', TIME, NULL) ORDER BY TIME), ',', COUNT(IF(COMMAND != 'Sleep', TIME, NULL))*95/100) AS DECIMAL(10,2)) AS median_95pct_active_time,
    MAX(IF(COMMAND != 'Sleep', TIME, NULL)) AS max_active_time,
    AVG(IF(COMMAND != 'Sleep', TIME, NULL)) AS average_active_time
  FROM 
    INFORMATION_SCHEMA.PROCESSLIST 
  WHERE 
    id != CONNECTION_ID()
  GROUP BY
    USER, SUBSTRING_INDEX(HOST, ':', 1)
;
