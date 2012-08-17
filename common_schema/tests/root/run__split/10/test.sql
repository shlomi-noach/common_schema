-- 4096 rows, 1000 rows per split step
SET @s := '
  split(test_cs.test_split)
  {
    update test_cs.test_split set nval=17 where :$split_clause;
  }
  ';
call run(@s);

select distinct nval = 17 from test_cs.test_split;
