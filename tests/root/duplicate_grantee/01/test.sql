call run('try drop user cs_test_user_cp@localhost; catch pass;');
call duplicate_grantee('cs_test_user@localhost', 'cs_test_user_cp@localhost');

select count(*) = 1 from sql_show_grants where user='cs_test_user_cp' and host='localhost';
