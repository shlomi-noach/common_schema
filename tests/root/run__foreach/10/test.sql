SET @@auto_increment_increment := 1;
SET @s := '
  foreach($a : {US, NZ, UK})
    foreach($b : 3:4)
    {
      INSERT INTO test_cs.test_script_foreach VALUES (NULL, CONCAT($a, '','', $b));
    }
';
call run(@s);
SELECT * FROM test_cs.test_script_foreach;

