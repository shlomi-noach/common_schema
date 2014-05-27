CALL foreach('table in test_cs_foreach', 'INSERT INTO test_cs.test_foreach VALUES(\'${table}\')');
SELECT * FROM test_cs.test_foreach ORDER BY name;
