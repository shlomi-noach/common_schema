-- 
-- Active processes sorted by current query runtime, desc (longest first). Exclude current connection.
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW processlist_top AS
  SELECT 
    *,
    CONCAT('KILL QUERY ', PROCESSLIST.ID) AS sql_kill_query,
    CONCAT('KILL ', PROCESSLIST.ID) AS sql_kill_connection    
  FROM 
    INFORMATION_SCHEMA.PROCESSLIST 
  WHERE 
    COMMAND != 'Sleep'
    AND id != CONNECTION_ID()
  ORDER BY
    TIME DESC
;
