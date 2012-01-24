-- 
-- Get slave hosts: hosts connected to this server and replicating from it 
-- (i.e. their process is doing 'Binlog Dump')
-- 

CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW slave_hosts AS
  SELECT 
    SUBSTRING_INDEX(HOST, ':', 1) AS host
  FROM 
    processlist_repl
  WHERE 
    is_slave IS TRUE
;
