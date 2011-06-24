-- 
-- State of processes per user/host: connected, executing, average execution time
-- 
CREATE OR REPLACE
ALGORITHM = UNDEFINED
SQL SECURITY INVOKER
VIEW processlist_per_userhost AS
  SELECT 
    USER AS user,
    SUBSTRING_INDEX(HOST, ':', 1) AS host,
    COUNT(*) AS count_processes,
    SUM(COMMAND != 'Sleep') AS active_processes,
    AVG(IF(COMMAND != 'Sleep', TIME, NULL)) AS average_active_time
  FROM 
    INFORMATION_SCHEMA.PROCESSLIST 
  WHERE 
    id != CONNECTION_ID()
  GROUP BY
    USER, SUBSTRING_INDEX(HOST, ':', 1)
;
