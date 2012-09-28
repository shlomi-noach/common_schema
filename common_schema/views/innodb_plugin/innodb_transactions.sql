-- 
-- Active InnoDB transactions
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW innodb_transactions AS
  SELECT 
    INFORMATION_SCHEMA.INNODB_TRX.*, 
    PROCESSLIST.INFO,
    TIMESTAMPDIFF(SECOND, trx_started, SYSDATE()) as trx_runtime_seconds,
    TIMESTAMPDIFF(SECOND, trx_wait_started, SYSDATE()) as trx_wait_seconds,
    IF(PROCESSLIST.COMMAND = 'Sleep', PROCESSLIST.TIME, 0) AS trx_idle_seconds,
    CONCAT('KILL QUERY ', trx_mysql_thread_id) AS sql_kill_query,
    CONCAT('KILL ', trx_mysql_thread_id) AS sql_kill_connection    
  FROM 
    INFORMATION_SCHEMA.INNODB_TRX
    LEFT JOIN INFORMATION_SCHEMA.PROCESSLIST ON (trx_mysql_thread_id = PROCESSLIST.ID)
  WHERE 
    trx_mysql_thread_id != CONNECTION_ID()
;
