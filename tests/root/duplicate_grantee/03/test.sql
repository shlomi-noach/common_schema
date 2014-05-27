call run('try drop user cs_test_user_cp@localhost; catch pass;');
call duplicate_grantee('cs_test_user@localhost', 'cs_test_user_cp@localhost');

select
  similar_grantees
from
  similar_grants
where
  sample_grantee in ("'cs_test_user'@'localhost'", "'cs_test_user_cp'@'localhost'")
into
  @similar_grantees;
;


select 
  find_in_set("'cs_test_user'@'localhost'", @similar_grantees) > 0
  and find_in_set("'cs_test_user_cp'@'localhost'", @similar_grantees) > 0
;
