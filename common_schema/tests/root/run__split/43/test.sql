
SET @s := '
  set @counter := 0;
  split({table: test_cs.test_split_complex_unique, start: 17})
  {
    set @counter := @counter + 1;
  }
  ';
call run(@s);

select @counter = 5;

