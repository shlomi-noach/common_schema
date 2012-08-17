set @counter := 0;
SET @s := '
  split(delete from test_cs.test_split_twin where id % 100 = 0)
  {
  }
  ';
call run(@s);


select count(*) = 4056 from test_cs.test_split_twin;