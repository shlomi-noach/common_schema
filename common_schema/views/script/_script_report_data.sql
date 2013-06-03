
-- 
-- Present only QueryScript report data relevant to current session
-- 

CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW _script_report_data AS
  SELECT 
    *
  FROM
    _global_script_report_data
  WHERE
    session_id = CONNECTION_ID()
;
