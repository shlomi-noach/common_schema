CALL foreach('table like test_foreach_table_%', 'INSERT INTO test_cs.test_foreach VALUES(\'${schema} ${table}\')');
SELECT * FROM test_cs.test_foreach ORDER BY name;
