SET @s := '
  set @x := 3;
  set @result := TRUE;
  while (@x > 0)
  {
    var $a;
    if ($a is not null)
    {
      set @result := FALSE; 
    }
    set $a := 17;
    set @x := @x - 1;
  }
';
call run(@s);

select @result IS TRUE;

