SET @s := '{
  set @x := 6;
  if  (@x % 2 = 1)
  {
    set @x := @x + 1;
  }
  set @y := @x + 1;
}
';

call run(@s);

SELECT @x = 6 AND @y = 7;

