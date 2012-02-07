SET @s := '{
  set @y := 0;
  set @x := 3;
  while (@x > 0)
  {
    set @x := @x - 1;
    set @y := @y + 1;
  }
}
';

call run(@s);

SELECT @x = 0 and @y = 3;

