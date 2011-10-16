CALL foreach('schema like test_cs_foreach_%', 'INSERT INTO test_cs.test_foreach VALUES(\'${schema}\')');
SELECT * FROM test_cs.test_foreach ORDER BY name;
