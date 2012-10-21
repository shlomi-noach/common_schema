SET @@auto_increment_increment := 1;
SET @s := '
  foreach($a : {US, NZ, UK})
  {
    INSERT INTO test_cs.test_script_foreach VALUES (NULL, $a);
  }
';
call run(@s);
SELECT * FROM test_cs.test_script_foreach;

