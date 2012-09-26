-- 
-- 
-- 

CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW _sql_accounts_base AS
  SELECT 
    user,
    host,
    mysql_grantee(user, host) AS grantee,
    password,
    password = '' or password rlike '^[?]{41}$' as is_empty_password,
    password rlike '^[*][0-9a-fA-F]{40}$' or password rlike '^[0-9a-fA-F]{40}[*]$' as is_new_password,
    password rlike '^[0-9a-fA-F]{16}$' or password rlike '^[~]{25}[0-9a-fA-F]{16}$' as is_old_password,
    password rlike '^[0-9a-fA-F]{40}[*]$' or password rlike '^[~]{25}[0-9a-fA-F]{16}$' or password rlike '^[?]{41}$' as is_blocked,
    REVERSE(password) AS reversed_password,
    REPLACE(password, '~', '') AS untiled_password,
    CONCAT(REPEAT('~', IF(CHAR_LENGTH(password) = 16, 25, 0)), password) AS tiled_password
  FROM
    mysql.user
;


-- 
-- 
-- 

CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW _sql_accounts_password AS
  SELECT
    *,
    CASE
      WHEN is_blocked THEN password
      WHEN is_empty_password THEN REPEAT('?', 41)
      WHEN is_new_password THEN reversed_password
      WHEN is_old_password THEN tiled_password
    END as password_for_sql_block_account,
    CASE
      WHEN not is_blocked THEN password
      WHEN is_empty_password THEN ''
      WHEN is_new_password THEN reversed_password
      WHEN is_old_password THEN untiled_password
    END as password_for_sql_release_account    
  FROM
    _sql_accounts_base
;

-- 
-- Generate SQL statements to block/release accounts. Provide info on accounts.
-- 

CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW sql_accounts AS
  SELECT
    user,
    host,
    grantee,
    password,
    is_empty_password,
    is_new_password or is_empty_password as is_new_password,
    is_old_password,
    is_blocked,
    CONCAT('SET PASSWORD FOR ', grantee, ' = ''', password_for_sql_block_account, '''') as sql_block_account,
    CONCAT('SET PASSWORD FOR ', grantee, ' = ''', password_for_sql_release_account, '''') as sql_release_account    
  FROM
    _sql_accounts_password
;
