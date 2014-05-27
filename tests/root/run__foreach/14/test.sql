SET @s := '
  set @sum := 0;
  set @other := 17;
  foreach($a : 1:3)
  {
    set @sum := @sum + $a;
  }
  otherwise 
  {
    set @other := 41;
  }
';
call run(@s);
SELECT @sum = 6 and @other = 17;

