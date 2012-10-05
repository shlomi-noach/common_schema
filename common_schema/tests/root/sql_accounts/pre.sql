SET @s := '
try drop user cs_test_user@localhost;
catch pass;

grant usage on *.* to cs_test_user@localhost identified by ''123'';
';
call run(@s);
