-- 4096 rows, 1000 rows per split step
SET @s := '
  set @counter := 0;
  var $t := "test_split";
  split(test_cs.:$t)
  {
    set @counter := @counter + 1;
  }
  ';
call run(@s);

select @counter = 5;

