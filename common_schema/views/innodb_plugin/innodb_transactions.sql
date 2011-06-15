-- 
-- Active InnoDB transactions
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW innodb_transactions AS
  SELECT 
    * 
  FROM 
    INFORMATION_SCHEMA.INNODB_TRX
  WHERE 
    trx_query IS NOT NULL
    AND trx_mysql_thread_id != CONNECTION_ID()
;
