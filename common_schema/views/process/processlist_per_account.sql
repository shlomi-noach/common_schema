-- 
-- Active processes sorted by current query runtime, desc (longest first). Exclude current connection.
-- 
CREATE OR REPLACE
ALGORITHM = UNDEFINED
SQL SECURITY INVOKER
VIEW processlist_per_account AS
  SELECT 
    USER, 
    SUBSTRING_INDEX(HOST, ':', 1) AS host,
    COUNT(*) AS count_processes,
    SUM(COMMAND != 'Sleep') AS active_processes,
    AVG(IF(COMMAND != 'Sleep', TIME, NULL)) AS average_active_time
  FROM 
    INFORMATION_SCHEMA.PROCESSLIST 
  GROUP BY
    USER, SUBSTRING_INDEX(HOST, ':', 1)
;
