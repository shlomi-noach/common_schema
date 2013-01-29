
DROP TABLE IF EXISTS `routine_privileges`;
CREATE TABLE IF NOT EXISTS `routine_privileges` (
  `GRANTEE` varchar(81),
  `ROUTINE_CATALOG` binary(0),
  `ROUTINE_SCHEMA` char(64),
  `ROUTINE_NAME` char(64),
  `ROUTINE_TYPE` enum('FUNCTION','PROCEDURE'),
  `PRIVILEGE_TYPE` varchar(27),
  `IS_GRANTABLE` varchar(3)
) ENGINE=MyISAM;

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
      '' AS object_type,
      NULL AS object_schema,
      NULL AS object_name,
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
      '' AS object_type,
      NULL AS object_schema,
      NULL AS object_name,
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
      '' AS object_type,
      NULL AS object_schema,
      TABLE_SCHEMA AS object_name,
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
      'table' AS object_type,
      TABLE_SCHEMA AS object_schema,
      TABLE_NAME AS object_name,
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
      '' AS object_type,
      TABLE_SCHEMA AS object_schema,
      TABLE_NAME AS object_name,
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
      MAX(ROUTINE_TYPE) AS object_type,
      ROUTINE_SCHEMA AS object_schema,
      ROUTINE_NAME AS object_name,
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
    object_schema,
    object_name,
    current_privileges,
    IS_GRANTABLE,
    CONCAT(
      'GRANT ', current_privileges, 
      ' ON ', IF(priv_level_name = 'routine', CONCAT(object_type, ' '), ''), priv_level, 
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

-- 
-- _bare_grantee_grants: just the grants per grantee, exluding the grantee name and password from statements  
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW _bare_grantee_grants AS
  SELECT
    GRANTEE,
    user,
    host,
    GROUP_CONCAT(
      CONCAT(
        SUBSTRING_INDEX(
          REPLACE(sql_grant, GRANTEE, ''), 
          'IDENTIFIED BY PASSWORD', 
          1), 
        ';')
      ORDER BY sql_grant
      SEPARATOR '\n'
      ) AS sql_grants
  FROM
    sql_grants
  GROUP BY
    GRANTEE, user, host
;


-- 
-- _bare_grantee_grants: just the grants per grantee, exluding USAGE (which is shared by all), and exluding the grantee name from statement  
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW similar_grants AS
  SELECT
    MIN(GRANTEE) AS sample_grantee,
    COUNT(GRANTEE) AS count_grantees,
    GROUP_CONCAT(GRANTEE ORDER BY GRANTEE) AS similar_grantees
  FROM
    _bare_grantee_grants
  GROUP BY
    sql_grants
  ORDER BY
    COUNT(*) DESC
;


