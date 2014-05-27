SET @s := '
  update test_cs.test_split set nval = 0;
  split(test_cs.test_split: update test_cs.test_split set nval = nval + 1 where id % 100 = 0)
  {
    if (@query_script_split_step_index = 2)
      break;
  }
  ';
call run(@s);

select count(*) = 20 from test_cs.test_split where nval = 1;

