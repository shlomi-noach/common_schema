update test_cs.test_split set nval = 0;

SET @s := '
  split({foo: 3, table: test_cs.test_split, bar: 5}: update test_cs.test_split set nval = 1)
  {
  }
  ';
call run(@s);

select distinct nval = 1 from test_cs.test_split;

