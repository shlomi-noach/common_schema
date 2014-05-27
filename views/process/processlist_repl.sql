-- 
-- Replication processes only (both Master & Slave)
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW processlist_repl AS
  SELECT 
    PROCESSLIST.*,
    USER = 'system user' AS is_system,
    (USER = 'system user' AND state_type = 'replication_io_thread') IS TRUE AS is_io_thread,
    (USER = 'system user' AND state_type = 'replication_sql_thread') IS TRUE AS is_sql_thread,
    COMMAND = 'Binlog Dump' AS is_slave
  FROM 
    INFORMATION_SCHEMA.PROCESSLIST 
    LEFT JOIN _known_thread_states ON (_known_thread_states.state LIKE CONCAT(PROCESSLIST.STATE, '%'))
  WHERE 
    USER = 'system user'
    OR COMMAND = 'Binlog Dump'
;
