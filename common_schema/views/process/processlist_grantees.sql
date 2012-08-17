-- 
-- Active processes sorted by current query runtime, desc (longest first). Exclude current connection.
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW processlist_grantees AS
  SELECT 
    PROCESSLIST.ID,
    PROCESSLIST.USER,
    PROCESSLIST.HOST,
    PROCESSLIST.DB,
    PROCESSLIST.COMMAND,
    PROCESSLIST.TIME,
    PROCESSLIST.STATE,
    PROCESSLIST.INFO,
    USER_PRIVILEGES.GRANTEE,
    mysql.user.user AS grantee_user,
    mysql.user.host AS grantee_host,
    SUM(USER_PRIVILEGES.PRIVILEGE_TYPE = 'SUPER') AS is_super,
    (PROCESSLIST.USER = 'system user' OR PROCESSLIST.COMMAND = 'Binlog Dump') AS is_repl,
    id = CONNECTION_ID() AS is_current,
    CONCAT('KILL QUERY ', PROCESSLIST.ID) AS sql_kill_query,
    CONCAT('KILL ', PROCESSLIST.ID) AS sql_kill_connection
  FROM 
    INFORMATION_SCHEMA.PROCESSLIST 
    LEFT JOIN INFORMATION_SCHEMA.USER_PRIVILEGES ON (match_grantee(USER, HOST) = USER_PRIVILEGES.GRANTEE)
    LEFT JOIN mysql.user ON (CONCAT('''', mysql.user.user, '''@''', mysql.user.host, '''') = USER_PRIVILEGES.GRANTEE)
  GROUP BY
    PROCESSLIST.ID, PROCESSLIST.USER, PROCESSLIST.HOST, PROCESSLIST.DB, PROCESSLIST.COMMAND, PROCESSLIST.TIME, PROCESSLIST.STATE, PROCESSLIST.INFO, USER_PRIVILEGES.GRANTEE, mysql.user.user, mysql.user.host
;


-- 
-- Explode various grantee, user & host combinations
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW _processlist_grantees_exploded AS
  SELECT 
    id,
    sql_kill_query,
    sql_kill_connection,
    grantee,
    concat(grantee_user, '@', grantee_host) as unqualified_grantee,
    grantee_host,
    grantee_user,
    concat('''', user, '''@''', SUBSTRING_INDEX(host, ':', 1), '''') as qualified_user_host,
    concat(user, '@', SUBSTRING_INDEX(host, ':', 1)) as unqualified_user_host,
    SUBSTRING_INDEX(host, ':', 1) as hostname,
    user
  FROM
    processlist_grantees
;
