SET @s := '
  set @sum := 0;
  var $range_end := 5;
  foreach($a : 1::${range_end})
  {
    set @sum := @sum + $a;
  }
';
call run(@s);
SELECT @sum = 15;


