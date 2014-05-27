SET @s := '{
  set @y := 0;
  set @x := 3;
  loop {
    set @y := @y + 1;
    set @x := @x - 1;
    if (@x = 1)
      break;
  } while (@x > 0);
  set @z := 17;
}
';

call run(@s);

SELECT @y = 2 and @z = 17;

