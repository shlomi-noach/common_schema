update test_cs.test_split set nval = 1;

SET @s := '
  split({start: 31}: update test_cs.test_split set nval = nval + 1)
  {
  }
  ';
call run(@s);

select (sum(nval = 1) = 30) and (sum(nval = 2) = 4066) from test_cs.test_split;

