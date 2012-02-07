
SET @s := '
  foreach($tbl, $scm, $engine, $create_opts: table like test_script_foreach_table_%)
  {
    INSERT INTO test_cs.test_script_foreach VALUES($tbl, $scm, $engine, $create_opts);
  }
';
call run(@s);

SELECT tbl, scm, engine FROM test_cs.test_script_foreach ORDER BY scm, tbl;

