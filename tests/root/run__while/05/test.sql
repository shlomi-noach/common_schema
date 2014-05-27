SET @s := '{
  set @y := 0;
  set @x := 3;
  while (@x > 0)
  {
    if (@x = 1)
      break;
    set @x := @x - 1;
    set @y := @y + 1;
  }
  set @z := 11;
}
';

call run(@s);

SELECT @x = 1 and @y = 2 and @z = 11;

