
SET @s := '
  split(insert into test_cs.test_split_twin select * from test_cs.test_split)
  {
  }
  ';
call run(@s);

select count(*) = 4096 from test_cs.test_split_twin;