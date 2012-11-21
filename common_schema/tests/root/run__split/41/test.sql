update test_cs.test_split set nval = 1;

SET @s := '
  split({start: 31, stop: 3300}: update test_cs.test_split set nval = nval + 1)
  {
  }
  ';
call run(@s);

select min(id) = 31 and max(id) = 3300 from test_cs.test_split where nval = 2;

