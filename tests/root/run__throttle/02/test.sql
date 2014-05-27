SET @s := '
  set @x := 10;
  while (@x > 0)
  {
    set @x := @x -1;
    throttle 0.01
  }
';
call run(@s);

select @x = 0;
