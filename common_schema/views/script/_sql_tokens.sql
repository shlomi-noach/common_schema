
-- 
-- Present only sql_tokens relevant to current session
-- 

CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW _sql_tokens AS
  SELECT 
    *
  FROM
    _global_sql_tokens
  WHERE
    session_id = CONNECTION_ID()
with check option
;
