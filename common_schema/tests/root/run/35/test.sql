SET @s := '{
  set @y := 7;
  set @x := 0;
  loop
    set @y := @y + 1;
  while (@x > 0);
}
';

call run(@s);

SELECT @y = 8;

