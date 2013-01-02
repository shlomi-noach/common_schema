call run('try drop user cs_test_user_cp@localhost; catch pass;');
call duplicate_grantee('cs_test_user@localhost', 'cs_test_user_cp@localhost');

select 
  GRANTEE, TABLE_SCHEMA, PRIVILEGE_TYPE 
from 
  information_schema.schema_privileges 
where 
  GRANTEE="'cs_test_user_cp'@'localhost'";
