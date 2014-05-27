SET @s := '
  set @sum := 0;
  var $range := ''2:5'';
  foreach($a : :${range})
  {
    set @sum := @sum + $a;
  }
';
call run(@s);
SELECT @sum = 14;


