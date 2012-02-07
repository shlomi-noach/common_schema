SET @s := '
  foreach($a : 0:2)
    foreach($b : 3:4)
    {
      INSERT INTO test_cs.test_script_foreach VALUES (NULL, CONCAT($a, '','', $b));
    }
';
call run(@s);
SELECT * FROM test_cs.test_script_foreach;

