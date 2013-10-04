
-- 
-- Present only QueryScript functions relevant to current session
-- 

CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW _qs_functions AS
  SELECT 
    *
  FROM
    _global_qs_functions
  WHERE
    session_id = CONNECTION_ID()
with check option
;
