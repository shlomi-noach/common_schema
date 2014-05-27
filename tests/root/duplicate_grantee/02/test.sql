call run('try drop user cs_test_user_cp@localhost; catch pass;');
call duplicate_grantee('cs_test_user@localhost', 'cs_test_user_cp@localhost');

select 
  count(password) = 2 and count(distinct password) = 1 
from 
  mysql.user 
where 
  user in ('cs_test_user', 'cs_test_user_cp') 
  and host='localhost'
;
