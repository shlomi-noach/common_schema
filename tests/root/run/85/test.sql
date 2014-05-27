SET @s := '
  var $x;
  set $x := 2;
  SELECT * FROM test_cs.test_script_expansion ORDER BY id DESC LIMIT :$x;
';
call run(@s);

