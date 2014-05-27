
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
    server_id = _get_server_id()
    and session_id = CONNECTION_ID()
with check option
;
