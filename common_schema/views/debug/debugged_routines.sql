
-- 
-- Lists routines that have debugging info    
-- 

CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW debugged_routines AS
  SELECT 
    ROUTINE_SCHEMA,
    ROUTINE_NAME,
    ROUTINE_TYPE,
    CONCAT('call `', DATABASE(), '`.rdebug_compile_routine(', QUOTE(ROUTINE_SCHEMA),', ', QUOTE(ROUTINE_NAME),', false)') AS sql_undebug_routine

  FROM
    INFORMATION_SCHEMA.ROUTINES
  WHERE 
    ROUTINE_DEFINITION LIKE CONCAT('%', _rdebug_get_debug_code_start(), '%')
;
