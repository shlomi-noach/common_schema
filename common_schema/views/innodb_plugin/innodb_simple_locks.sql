-- 
-- Simplification of INNODB_LOCKS table
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW innodb_simple_locks AS
  SELECT 
    lock_id,
    lock_trx_id,
    lock_type,
    lock_table,
    lock_index,
    lock_data
  FROM 
    INFORMATION_SCHEMA.INNODB_LOCKS
;
