SET @s := '
try drop user cs_test_user@localhost;
catch pass;
try drop user cs_test_user_cp@localhost;
catch pass;

GRANT USAGE ON *.* TO cs_test_user@localhost IDENTIFIED BY ''123'';
grant select, execute on test_cs.* to cs_test_user@localhost;
grant select (n) on common_schema.numbers to cs_test_user@localhost;
grant execute, alter routine on procedure common_schema.help to cs_test_user@localhost;
';
call run(@s);
