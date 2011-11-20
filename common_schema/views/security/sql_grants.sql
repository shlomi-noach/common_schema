-- 
-- (Internal use): privileges set on columns   
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW _columns_privileges AS
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
;

-- 
-- (Internal use): GRANTs, account details, privileges details   
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW _sql_grants_components AS
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
    FROM 
      _columns_privileges
    GROUP BY
      GRANTEE, TABLE_SCHEMA, TABLE_NAME
  )
  UNION ALL
  (
    SELECT
      GRANTEE,
      CONCAT('`', ROUTINE_SCHEMA, '`.`', ROUTINE_NAME, '`') AS priv_level,
      'routine' AS priv_level_name,
      GROUP_CONCAT(PRIVILEGE_TYPE ORDER BY PRIVILEGE_TYPE SEPARATOR ', ') AS current_privileges,
      MAX(IS_GRANTABLE) AS IS_GRANTABLE, 
      6 AS result_order
    FROM 
      routine_privileges
    GROUP BY
      GRANTEE, ROUTINE_SCHEMA, ROUTINE_NAME
  )
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
    END AS sql_revoke,
    CONCAT(
      'DROP USER ', GRANTEE
      ) AS sql_drop_user
  FROM 
    _sql_grants_components
    JOIN mysql.user ON (GRANTEE = CONCAT('''', user.user, '''@''', user.host, ''''))
  ORDER BY 
    GRANTEE, result_order
;


-- 
-- SHOW GRANTS like output, for all accounts  
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW sql_show_grants AS
  SELECT
    GRANTEE,
    user,
    host,
    GROUP_CONCAT(
      CONCAT(sql_grant, ';')
      SEPARATOR '\n'
      ) AS sql_grants
  FROM
    sql_grants
  GROUP BY
    GRANTEE, user, host
;
