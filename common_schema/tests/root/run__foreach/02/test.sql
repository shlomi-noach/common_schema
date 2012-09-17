SET @s := '
  foreach($a : 3:7)
  {
    INSERT INTO test_cs.test_script_foreach VALUES ($a, NULL);
  }
';
call run(@s);
SELECT * FROM test_cs.test_script_foreach;

