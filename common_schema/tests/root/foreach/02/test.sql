CALL foreach('{red green blue}', 'ALTER TABLE test_cs.test_foreach ADD COLUMN col_${1} INT DEFAULT ${NR}');
SELECT 
  MAX(col_red) = 1 
  AND MAX(col_green) = 2
  AND MAX(col_blue) = 3 
FROM test_cs.test_foreach;
