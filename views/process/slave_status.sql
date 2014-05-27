-- 
-- Provide with slave status info
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW slave_status AS
  SELECT 
    SUM(IF(is_io_thread, TIME, NULL)) AS Slave_Connected_time,
    SUM(is_io_thread) IS TRUE AS Slave_IO_Running,
    SUM(is_sql_thread OR (is_system AND NOT is_io_thread)) IS TRUE AS Slave_SQL_Running,
    (SUM(is_system) = 2) IS TRUE AS Slave_Running,
    SUM(IF(is_sql_thread OR (is_system AND NOT is_io_thread), TIME, NULL)) AS Seconds_Behind_Master
  FROM 
    processlist_repl
;
