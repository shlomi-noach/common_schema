
SET @s := '
  foreach($scm: schema like test_cs_foreach_%)
  {
    INSERT INTO test_cs.test_script_foreach VALUES($scm)
  }
';
call run(@s);

SELECT * FROM test_cs.test_script_foreach ORDER BY name;

