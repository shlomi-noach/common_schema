SET @s := '{
  set @x := 3;
  if  (@x % 2 = 1)
  {
    set @x := @x + 1;
  }
  set @y := 17;
}
';

call run(@s);

SELECT @x = 4 AND @y = 17;


