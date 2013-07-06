
SET @s := '
  set @counter := 0;
  split({table: test_cs.test_split_complex_unique, stop: ''1700,0,0''})
  {
    set @counter := @counter + 1;
  }
  ';
call run(@s);

select @counter = 2;

