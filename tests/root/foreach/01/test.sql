CALL foreach('2:5', 'UPDATE test_cs.test_foreach SET name=${NR} WHERE id=${1}');
SELECT * FROM test_cs.test_foreach;