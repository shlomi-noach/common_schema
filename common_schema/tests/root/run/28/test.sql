SET @s := '{
  set @x := 3;
  while (@x > 0)
    set @x := @x - 1;
}
';

call run(@s);

SELECT @x = 0;

