-- 4096 rows, 1000 rows per split step
SET @s := "
  split(test_cs.test_split_complex_unique)
  {
    update test_cs.test_split_complex_unique set textval='23' where :$split_clause;
  }
  ";
call run(@s);

select distinct textval = '23' from test_cs.test_split_complex_unique;
