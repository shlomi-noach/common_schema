SET @s := '{
  -- set @y := 4; 
  set @x := 3;
  -- @x := @x + 1;
}
';

call run(@s);

SELECT @x = 3 and @y is null;

