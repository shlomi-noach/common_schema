DROP TABLE IF EXISTS `routine_privileges`;

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
    REPLACE(UPPER(SUBSTRING_INDEX(SUBSTRING_INDEX(Proc_priv, ',', n+1), ',', -1)), '\0', ' ') AS PRIVILEGE_TYPE,
    IF(find_in_set('Grant', Proc_priv) > 0, 'YES', 'NO') AS IS_GRANTABLE
  FROM
    mysql.procs_priv
    CROSS JOIN numbers
  WHERE
    numbers.n BETWEEN 0 AND CHAR_LENGTH(Proc_priv) - CHAR_LENGTH(REPLACE(Proc_priv, ',', ''))
    AND UPPER(SUBSTRING_INDEX(SUBSTRING_INDEX(Proc_priv, ',', n+1), ',', -1)) != 'GRANT'
;
