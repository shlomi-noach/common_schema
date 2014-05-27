-- 4096 rows, 1000 rows per split step
SET @s := '
  set @counter := 0;
  split(test_cs.test_split_complex_unique)
  {
    set @counter := @counter + 1;
  }
  ';
call run(@s);

select @counter = 5;

