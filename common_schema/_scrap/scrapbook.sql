

SELECT
  CONCAT('\'', User, '\'@\'', Host, '\'') AS GRANTEE,
  NULL AS ROUTINE_CATALOG,
  Db AS ROUTINE_SCHEMA,
  Routine_name AS ROUTINE_NAME,
  Routine_type AS ROUTINE_TYPE,
  UPPER(SUBSTRING_INDEX(SUBSTRING_INDEX(Proc_priv, ',', n+1), ',', -1)) AS PRIVILEGE_TYPE,
  IF(grantable_procs_priv.User IS NULL, 'NO', 'YES') AS IS_GRANTABLE
FROM
  mysql.procs_priv
  CROSS JOIN numbers
  LEFT JOIN (
      SELECT 
        DISTINCT User, Host, Db, Routine_name
      FROM
        mysql.procs_priv
      WHERE 
         find_in_set('Grant', Proc_priv) > 0
    ) grantable_procs_priv USING (User, Host, Db, Routine_name)
WHERE
  numbers.n BETWEEN 0 AND CHAR_LENGTH(Proc_priv) - CHAR_LENGTH(REPLACE(Proc_priv, ',', ''))
  AND UPPER(SUBSTRING_INDEX(SUBSTRING_INDEX(Proc_priv, ',', n+1), ',', -1)) != 'GRANT'
;



SELECT STRAIGHT_JOIN
  CONCAT('\'', User, '\'@\'', Host, '\'') AS GRANTEE,
  NULL AS ROUTINE_CATALOG,
  Db AS ROUTINE_SCHEMA,
  Routine_name AS ROUTINE_NAME,
  Routine_type AS ROUTINE_TYPE,
  UPPER(SUBSTRING_INDEX(SUBSTRING_INDEX(Proc_priv, ',', n+1), ',', -1)) AS PRIVILEGE_TYPE,
  IF(grantable_procs_priv.User IS NULL, 'NO', 'YES') AS IS_GRANTABLE
FROM
  mysql.procs_priv
  CROSS JOIN (SELECT @counter := -1) select_init
  CROSS JOIN (
    SELECT
      @counter := @counter+1 AS n
    FROM
      INFORMATION_SCHEMA.COLLATIONS
    LIMIT 3
  ) numbers
  LEFT JOIN (
      SELECT 
        DISTINCT User, Host, Db, Routine_name
      FROM
        mysql.procs_priv
      WHERE 
         find_in_set('Grant', Proc_priv) > 0
    ) grantable_procs_priv USING (User, Host, Db, Routine_name)
WHERE
  numbers.n BETWEEN 0 AND CHAR_LENGTH(Proc_priv) - CHAR_LENGTH(REPLACE(Proc_priv, ',', ''))
  AND UPPER(SUBSTRING_INDEX(SUBSTRING_INDEX(Proc_priv, ',', n+1), ',', -1)) != 'GRANT'
ORDER BY
  GRANTEE, ROUTINE_SCHEMA, ROUTINE_NAME, ROUTINE_TYPE, n
;

-- 
-- Current grantee privileges and additional info breakdown, generated GRANT and REVOKE sql statements  
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW sql_grants AS
  SELECT 
    GRANTEE, 
    user.user,
    user.host,
    priv_level,
    priv_level_name,
    current_privileges,
    IS_GRANTABLE,
    CONCAT(
      'GRANT ', current_privileges, 
      ' ON ', priv_level, 
      ' TO ', GRANTEE,
      IF(priv_level = '*.*' AND current_privileges = 'USAGE', 
        CONCAT(' IDENTIFIED BY PASSWORD ''', user.password, ''''), ''),
      IF(IS_GRANTABLE = 'YES', 
        ' WITH GRANT OPTION', '')
      ) AS sql_grant,
    CASE
      WHEN current_privileges = 'USAGE' AND priv_level = '*.*' THEN ''
      ELSE
        CONCAT(
          'REVOKE ', current_privileges, 
          IF(IS_GRANTABLE = 'YES', 
            ', GRANT OPTION', ''),
          ' ON ', priv_level, 
          ' FROM ', GRANTEE
          )      
    END AS sql_revoke
  FROM (
    (
      SELECT 
        GRANTEE,
        '*.*' AS priv_level,
        'user' AS priv_level_name,
        'USAGE' AS current_privileges,
        MAX(IS_GRANTABLE) AS IS_GRANTABLE, 
        1 AS result_order
      FROM
        INFORMATION_SCHEMA.USER_PRIVILEGES
      GROUP BY
        GRANTEE
    )
    UNION ALL
    (
      SELECT 
        GRANTEE,
        '*.*' AS priv_level,
        'user' AS priv_level_name,
        GROUP_CONCAT(PRIVILEGE_TYPE ORDER BY PRIVILEGE_TYPE SEPARATOR ', ') AS current_privileges,
        MAX(IS_GRANTABLE) AS IS_GRANTABLE, 
        2 AS result_order
      FROM
        INFORMATION_SCHEMA.USER_PRIVILEGES
      GROUP BY
        GRANTEE
      HAVING
        GROUP_CONCAT(PRIVILEGE_TYPE ORDER BY PRIVILEGE_TYPE) != 'USAGE'
    )
    UNION ALL
    (
      SELECT
        GRANTEE,
        CONCAT('`', TABLE_SCHEMA, '`.*') AS priv_level,
        'schema' AS priv_level_name,
        GROUP_CONCAT(PRIVILEGE_TYPE ORDER BY PRIVILEGE_TYPE SEPARATOR ', ') AS current_privileges,
        MAX(IS_GRANTABLE) AS IS_GRANTABLE, 
        3 AS result_order
      FROM 
        INFORMATION_SCHEMA.SCHEMA_PRIVILEGES
      GROUP BY
        GRANTEE, TABLE_SCHEMA
    )
    UNION ALL
    (
      SELECT
        GRANTEE,
        CONCAT('`', TABLE_SCHEMA, '`.`', TABLE_NAME, '`') AS priv_level,
        'table' AS priv_level_name,
        GROUP_CONCAT(PRIVILEGE_TYPE ORDER BY PRIVILEGE_TYPE SEPARATOR ', ') AS current_privileges,
        MAX(IS_GRANTABLE) AS IS_GRANTABLE, 
        4 AS result_order
      FROM 
        INFORMATION_SCHEMA.TABLE_PRIVILEGES
      GROUP BY
        GRANTEE, TABLE_SCHEMA, TABLE_NAME
    )
    UNION ALL
    (
      SELECT
        GRANTEE,
        CONCAT('`', TABLE_SCHEMA, '`.`', TABLE_NAME, '`') AS priv_level,
        'column' AS priv_level_name,
        GROUP_CONCAT(column_privileges ORDER BY column_privileges SEPARATOR ', ') AS current_privileges,
        MAX(IS_GRANTABLE) AS IS_GRANTABLE, 
        5 AS result_order
      FROM (
        SELECT
          GRANTEE,
          TABLE_SCHEMA,
          TABLE_NAME,
          MAX(IS_GRANTABLE) AS IS_GRANTABLE, 
          CONCAT(
            PRIVILEGE_TYPE,
            ' (', GROUP_CONCAT(COLUMN_NAME ORDER BY COLUMN_NAME SEPARATOR ', '), ')'
            ) AS column_privileges    
        FROM
          INFORMATION_SCHEMA.COLUMN_PRIVILEGES
        GROUP BY
          GRANTEE, TABLE_SCHEMA, TABLE_NAME, PRIVILEGE_TYPE
        ) AS select_column_privileges
      GROUP BY
        GRANTEE, TABLE_SCHEMA, TABLE_NAME
    )
  ) AS select_grants
  JOIN mysql.user ON (GRANTEE = CONCAT('''', user.user, '''@''', user.host, ''''))
  ORDER BY 
    GRANTEE, result_order
;
