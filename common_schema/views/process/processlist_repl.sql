-- 
-- Replication processes only (both Master & Slave)
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW processlist_repl AS
  SELECT 
    * 
  FROM 
    INFORMATION_SCHEMA.PROCESSLIST 
  WHERE 
    USER = 'system user'
    OR COMMAND = 'Binlog Dump'
;
