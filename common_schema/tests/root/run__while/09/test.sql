SET @s := '{
  set @y := 0;
  set @x := 3;
  set @other := 17;
  while (@x > 0)
  {
    set @x := @x - 1;
    set @y := @y + 1;
  }
  otherwise {
    set @other := 41;
  }
}
';

call run(@s);

SELECT @x = 0 and @y = 3 and @other = 17;

