update test_cs.test_split set nval = 1;

SET @s := '
  var $incr := 5;
  split(update test_cs.test_split set nval = nval + :$incr)
  {
  }
  ';
call run(@s);

select distinct nval = 6 from test_cs.test_split;

