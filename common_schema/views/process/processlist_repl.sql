-- 
-- Replication processes only (both Master & Slave)
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW processlist_repl AS
  SELECT 
    *,
    USER = 'system user' AS is_system,
    COMMAND = 'Binlog Dump' AS is_slave
  FROM 
    INFORMATION_SCHEMA.PROCESSLIST 
  WHERE 
    USER = 'system user'
    OR COMMAND = 'Binlog Dump'
;
