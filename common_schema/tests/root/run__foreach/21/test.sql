SET @s := '
  set @sum := 0;
  var $range_end := 5;
  foreach($a : select n from numbers where n between 2 and $range_end)
  {
    set @sum := @sum + $a;
  }
';
call run(@s);
SELECT @sum = 14;


