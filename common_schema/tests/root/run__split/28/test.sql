update test_cs.test_split set nval = 0;

SET @s := '
  split(test_cs.test_split: update test_cs.test_split set nval = 1)
  {
  }
  split(test_cs.test_split: update test_cs.test_split set nval = nval + 17)
  {
  }
  ';
call run(@s);

select distinct nval = 18 from test_cs.test_split;

