-- 4096 rows, 1000 rows per split step
SET @s := '
  set @counter := 0;
  split({foo: test_cs.test_split})
  {
    set @counter := @counter + 1;
  }
  ';
call run(@s);

select @counter = 5;

