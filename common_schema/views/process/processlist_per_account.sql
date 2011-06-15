-- 
-- Active processes sorted by current query runtime, desc (longest first). Exclude current connection.
-- 
CREATE OR REPLACE
ALGORITHM = UNDEFINED
SQL SECURITY INVOKER
VIEW processlist_per_account AS
  SELECT 
    USER, 
    HOST,
    COUNT(*) AS count_processes,
    SUM(COMMAND != 'Sleep') AS active_processes,
    AVG(IF(COMMAND != 'Sleep', TIME, NULL)) AS average_active_time
  FROM 
    INFORMATION_SCHEMA.PROCESSLIST 
  WHERE 
    COMMAND != 'Sleep'
  GROUP BY
    USER, HOST
;
