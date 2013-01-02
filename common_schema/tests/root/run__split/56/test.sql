-- 4096 rows, 500 rows per split step
SET @s := '
  set @counter := 0;
  update test_cs.test_split set nval = 1;
  split({size: 500}: update test_cs.test_split set nval = nval + 1)
  {
    set @counter := @counter + 1;
  }
  ';
call run(@s);

select @counter = 9;

