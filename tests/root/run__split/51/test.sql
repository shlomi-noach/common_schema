-- 4096 rows, 1000 rows per split step
SET @s := '
  set @counter := 0;
  var $s := "test_cs";
  var $t := "test_split";
  update test_cs.test_split set nval = 1;
  split(update :$s.:$t set nval = nval + 1)
  {
    set @counter := @counter + 1;
  }
  ';
call run(@s);

select @counter = 5;

