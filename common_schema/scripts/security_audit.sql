
report h1 'Checking for non-local root accounts';
set @loop_counter := 0;
foreach ($user, $host: select user, host from mysql.user where user='root' and host not in ('127.0.0.1', 'localhost'))
{
  if ((@loop_counter := @loop_counter+1) = 1) {
    report 'Recommendation: limit following root accounts to local machines';
  }
  report code 'rename ', mysql_grantee($user, $host), ' to ', quote($user), '@', quote('localhost'); 
}
otherwise
  report 'OK';

  
report h1 'Checking for anonymous users';
set @loop_counter := 0;
foreach ($user, $host: select user, host from mysql.user where user='')
{
  if ((@loop_counter := @loop_counter+1) = 1) {
    report 'Recommendation: Drop these users and do not use them';
  }
  report code 'drop user ', mysql_grantee($user, $host); 
}
otherwise
  report 'OK';

  
report h1 'Looking for accounts accessible from any host';
set @loop_counter := 0;
foreach ($user, $host: select user, host from mysql.user where host in ('%', ''))
{
  if ((@loop_counter := @loop_counter+1) = 1) {
    report 'Recommendation: limit following accounts to specific hosts/subnet';
  }
  report code 'rename user ', mysql_grantee($user, $host), ' to ', mysql_grantee($user, '<specific host>'); 
}
otherwise
  report 'OK';


report h1 'Checking for accounts with empty passwords';
set @loop_counter := 0;  
foreach ($user, $host: select user, host from mysql.user where password='')
{
  if ((@loop_counter := @loop_counter+1) = 1) {
    report 'Recommendation: set a decent password to these accounts.';
  }
  report code 'set password for ', mysql_grantee($user, $host), ' = PASSWORD(...)';
}
otherwise
  report 'OK';

report h1 'Looking for accounts with identical (non empty) passwords';
set @loop_counter := 0;  
drop temporary table if exists _security_audit_identical_passwords;
create temporary table _security_audit_identical_passwords (
  user  varchar(128),
  host  varchar(128),
  password varchar(128),
  KEY (password)
) engine=MyISAM;

insert into _security_audit_identical_passwords
  SELECT 
    user, host, password 
  FROM (
    SELECT 
      user1.user, user1.host, 
      user2.user AS u2, user2.host AS h2, 
      min(user1.password) as password 
    FROM 
      mysql.user AS user1 
      INNER JOIN mysql.user AS user2 ON (user1.password = user2.password) 
    WHERE 
      user1.user != user2.user 
      AND user1.password != ''
  ) users 
  GROUP BY 
    user, host 
  ORDER BY 
    password
;
foreach ($password: select password from _security_audit_identical_passwords group by password)
{
  if ((@loop_counter := @loop_counter+1) = 1) {
    report 'Different users should not share same password.';
    report 'Recommendation: Change passwords for accounts listed below.';
  }
  report p 'The following accounts share the same password:';
  foreach ($user, $host: select user, host from _security_audit_identical_passwords where password = $password)
  	report mysql_grantee($user, $host);
}
otherwise
  report 'OK';


report h1 'Looking for (non-root) accounts with admin privileges';
set @loop_counter := 0;  
foreach ($grantee: SELECT GRANTEE, GROUP_CONCAT(PRIVILEGE_TYPE) AS privileges 
  FROM information_schema.USER_PRIVILEGES 
  WHERE PRIVILEGE_TYPE IN ('SUPER', 'SHUTDOWN', 'RELOAD', 'PROCESS', 'CREATE USER', 'REPLICATION CLIENT') 
  and grantee not like '''root''@%'
  GROUP BY GRANTEE)
{
  if ((@loop_counter := @loop_counter+1) = 1) {
    report 'Normal users should not have admin privileges, such as';
    report 'SUPER, SHUTDOWN, RELOAD, PROCESS, CREATE USER, REPLICATION CLIENT.';
    report 'Recommendation: limit privileges to following accounts.';
  }
  report code 'GRANT <non-admin-privileges> ON *.* TO ', $grantee; 
}
otherwise
  report 'OK';


report h1 'Looking for (non-root) accounts with global DDL privileges';
set @loop_counter := 0;  
foreach ($grantee: SELECT GRANTEE, GROUP_CONCAT(PRIVILEGE_TYPE) AS privileges 
  FROM information_schema.USER_PRIVILEGES 
  WHERE PRIVILEGE_TYPE IN ('CREATE', 'DROP', 'EVENT', 'ALTER', 'INDEX', 'TRIGGER', 'CREATE VIEW', 'ALTER ROUTINE', 'CREATE ROUTINE') 
  and grantee not like '''root''@%'
  GROUP BY GRANTEE)
{
  if ((@loop_counter := @loop_counter+1) = 1) {
    report 'Normal users should not have global DDL privileges, such as';
    report 'CREATE, DROP, EVENT, ALTER, INDEX, TRIGGER, CREATE VIEW, ...';
    report 'Recommendation: limit privileges to following accounts.';
  }
  report code 'GRANT <non-ddl-privileges> ON *.* TO ', $grantee; 
}
otherwise
  report 'OK';

  
report h1 'Looking for (non-root) accounts with global DML privileges';
set @loop_counter := 0;  
foreach ($grantee: SELECT GRANTEE, GROUP_CONCAT(PRIVILEGE_TYPE) AS privileges 
  FROM information_schema.USER_PRIVILEGES 
  WHERE PRIVILEGE_TYPE IN ('DELETE', 'INSERT', 'UPDATE', 'CREATE TEMPORARY TABLES') 
  and grantee not like '''root''@%'
  GROUP BY GRANTEE)
{
  if ((@loop_counter := @loop_counter+1) = 1) {
    report 'Normal users should not have global DML privileges.';
    report 'Such privileges allow these users operation on the mysql system tables.';
    report 'Recommendation: limit privileges to following accounts, so as';
    report 'to act on specific schemas.';
  }
  report code 'GRANT <dml-privileges> ON *.''<specific_schema>'' TO ', $grantee; 
}
otherwise
  report 'OK';


report h1 'Testing sql_mode';
if (FIND_IN_SET('NO_AUTO_CREATE_USER', @@global.sql_mode) = 0) {
  report 'Server''s sql_mode does not include NO_AUTO_CREATE_USER.';
  report 'This means users can be created with empty passwords.';
  report 'Recommendation: add NO_AUTO_CREATE_USER to sql_mode,';
  report 'both in config file as well as dynamically.';
  report code 'SET @@global.sql_mode := CONCAT(@@global.sql_mode, '',NO_AUTO_CREATE_USER'')'; 
}
else
  report 'OK';

  
report h1 'Testing old_passwords';
if (select @@global.old_passwords) {
  report 'This server is running with @@old_passwords = 1.';
  report 'This means password encryption is very weak.';
  report 'Recommendation: remove ''all_passwords'' config, and reset passwords';
  report 'for all accounts.'; 
}
else
  report 'OK';

  
report h1 'Checking for `test` database';
foreach ($schema: schema like test) {
  report '`test` database has been found.';
  report '`test` is a special database where any user can create, drop and manipulate';
  report 'table data. Recommendation: drop it';
  report code 'DROP DATABASE `test`'; 
}
otherwise
  report 'OK';

report '';

