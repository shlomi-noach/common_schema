SET @s := '{
  set @y := 7;
  set @x := 0;
  while (@x > 0)
    set @y := @y + 1;
}
';

call run(@s);

SELECT @y = 7;

