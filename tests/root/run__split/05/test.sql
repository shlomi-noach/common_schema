SET @s := '
  update test_cs.test_split set nval = 0;
  split(test_cs.test_split: update test_cs.test_split set nval = nval + 1 where id % 100 = 0)
  {
    select $split_step, $split_rowcount, $split_total_rowcount, $split_table_schema, $split_table_name;
  }
  ';
call run(@s);

