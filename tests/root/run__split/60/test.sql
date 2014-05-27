-- 4096 rows, 1000 rows per split step
SET @s := '
  split(test_cs.test_split)
  {
    select $split_range_start, $split_range_end;
  }
  ';
call run(@s);

