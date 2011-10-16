CALL foreach('SELECT id, name FROM test_cs.test_foreach', 'INSERT INTO test_cs.test_foreach_aid (id, name) VALUES (${1}, \'${2}\'); UPDATE test_cs.test_foreach_aid SET extra = \'${1}_${2}\' WHERE id = ${1};');
SELECT * FROM test_cs.test_foreach_aid ORDER BY id ASC;
