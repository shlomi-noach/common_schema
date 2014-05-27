-- 
-- One liner summary info on InnoDB transactions (count, running, locked, locks)
-- 
CREATE OR REPLACE
ALGORITHM = UNDEFINED
SQL SECURITY INVOKER
VIEW innodb_transactions_summary AS
  SELECT 
    COUNT(*) AS count_transactions,
    IFNULL(SUM(trx_state = 'RUNNING'), 0) AS running_transactions,
    IFNULL(SUM(trx_requested_lock_id IS NOT NULL), 0) AS locked_transactions,
    COUNT(DISTINCT trx_requested_lock_id) AS distinct_locks
  FROM 
    INFORMATION_SCHEMA.INNODB_TRX
  WHERE 
    trx_mysql_thread_id != CONNECTION_ID()
;
