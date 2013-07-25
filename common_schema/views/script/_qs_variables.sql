
-- 
-- Present only QueryScript variables relevant to current session
-- 

CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW _qs_variables AS
  SELECT 
    *
  FROM
    _global_qs_variables
  WHERE
    session_id = CONNECTION_ID()
with check option
;
