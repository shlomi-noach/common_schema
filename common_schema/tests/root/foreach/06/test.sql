CALL foreach('{   red green   blue }', 'INSERT INTO test_cs.test_foreach VALUES(${NR}, \'${1}\')');
SELECT * FROM test_cs.test_foreach;
