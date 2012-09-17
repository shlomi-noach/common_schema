
SET @s := '
  foreach($id, $name: SELECT id, name FROM test_cs.test_script_foreach)
  {
    UPDATE test_cs.test_script_foreach SET extra = CONCAT($id, '','', $name) WHERE id = $id;
  }
';
call run(@s);
SELECT * FROM test_cs.test_script_foreach;

