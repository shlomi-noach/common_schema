-- 
-- (Internal use): grantees with grant option on routines   
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW _grantable_procs_priv AS
  SELECT 
    DISTINCT User, Host, Db, Routine_name
  FROM
    mysql.procs_priv
  WHERE 
     find_in_set('Grant', Proc_priv) > 0
;

-- 
-- INFORMATION_SCHEMA-like privileges on routines    
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW routine_privileges AS
  SELECT
    CONCAT('\'', User, '\'@\'', Host, '\'') AS GRANTEE,
    NULL AS ROUTINE_CATALOG,
    Db AS ROUTINE_SCHEMA,
    Routine_name AS ROUTINE_NAME,
    Routine_type AS ROUTINE_TYPE,
    UPPER(SUBSTRING_INDEX(SUBSTRING_INDEX(Proc_priv, ',', n+1), ',', -1)) AS PRIVILEGE_TYPE,
    IF(_grantable_procs_priv.User IS NULL, 'NO', 'YES') AS IS_GRANTABLE
  FROM
    mysql.procs_priv
    CROSS JOIN numbers
    LEFT JOIN _grantable_procs_priv USING (User, Host, Db, Routine_name)
  WHERE
    numbers.n BETWEEN 0 AND CHAR_LENGTH(Proc_priv) - CHAR_LENGTH(REPLACE(Proc_priv, ',', ''))
    AND UPPER(SUBSTRING_INDEX(SUBSTRING_INDEX(Proc_priv, ',', n+1), ',', -1)) != 'GRANT'
;
