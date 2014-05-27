SET @s := '
  split(insert into test_cs.test_split_twin select * from test_cs.test_split where id % 100 = 0)
  {
  }
  ';
call run(@s);


select count(*) = 40 from test_cs.test_split_twin;