SET @s := '{
  set @x := 3;
  set @x := @x + 1;
  set @x := @x * 2;
}
';

call run(@s);

SELECT @x = 8;

