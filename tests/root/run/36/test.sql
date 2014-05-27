SET @s := '{
  set @y := 0;
  set @x := 3;
  loop {
    set @y := @y + 1;
    set @x := @x - 1;
  } while (@x > 0);
}
';

call run(@s);

SELECT @y = 3;

