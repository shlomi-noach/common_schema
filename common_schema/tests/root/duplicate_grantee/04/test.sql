call run('try drop user cs_test_user_cp@localhost; catch pass;');
call duplicate_grantee('cs_test_user@localhost', 'cs_test_user_cp@localhost');

select
  TABLE_NAME = 'numbers'
  AND COLUMN_NAME = 'n'
  AND PRIVILEGE_TYPE = 'SELECT'
from 
  information_schema.column_privileges 
where 
  GRANTEE="'cs_test_user_cp'@'localhost'";
