update test_cs.test_split set nval = 1;

SET @s := '
  split(update test_cs.test_split set nval = nval + 1)
  {
  }
  ';
call run(@s);

select distinct nval = 2 from test_cs.test_split;

