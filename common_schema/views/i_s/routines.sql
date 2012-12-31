
-- 
-- Complement INFORMATION_SCHEMA.ROUTINES with missing param_list    
-- 

CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW routines AS
  SELECT 
    ROUTINES.*, proc.param_list
  FROM
    INFORMATION_SCHEMA.ROUTINES
    JOIN mysql.proc ON (db = ROUTINE_SCHEMA and name = ROUTINE_NAME and type = ROUTINE_TYPE)
;
