-- 4096 rows, 2000 rows per split step
SET @s := '
  set @counter := 0;
  update test_cs.test_split set nval = 1;
  split({size: 2000}: update test_cs.test_split set nval = nval + 1)
  {
    set @counter := @counter + 1;
  }
  ';
call run(@s);

select @counter = 3;

