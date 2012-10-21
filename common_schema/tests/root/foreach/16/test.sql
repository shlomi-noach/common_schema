set @result := '';
set @@auto_increment_increment :=1;

CALL foreach('0:2,3:4', '
  input $x, $y;

  INSERT INTO test_cs.test_foreach VALUES (NULL, CONCAT($x, '','', $y));
');

SELECT * FROM test_cs.test_foreach;

