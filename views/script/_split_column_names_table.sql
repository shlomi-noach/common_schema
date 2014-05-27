
-- 
-- Present only QueryScript variables relevant to current session
-- 

CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW _split_column_names_table AS
  SELECT 
    *
  FROM
    _global_split_column_names_table
  WHERE
    session_id = CONNECTION_ID()
with check option
;
