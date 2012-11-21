update test_cs.test_split set nval = 1;

SET @s := '
  set @counter := 0;
  var $start := 31;
  var $stop := 3300;
  split({start: :${start}, stop::$stop}: update test_cs.test_split set nval = nval + 1)
  {
    set @counter := @counter + 1;
  }
  ';
call run(@s);

select (@counter = 4) and min(id) = 31 and max(id) = 3300 from test_cs.test_split where nval = 2;

