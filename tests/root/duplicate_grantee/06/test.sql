call run('try drop user cs_test_user_cp@localhost; catch pass;');
call duplicate_grantee('cs_test_user@localhost', 'cs_test_user_cp@localhost');

select
  Routine_name = 'help'
  AND db = 'common_schema'
  AND Proc_priv = 'Execute,Alter Routine'
from 
  mysql.procs_priv 
where 
  user = 'cs_test_user_cp'
  and host = 'localhost'
;
