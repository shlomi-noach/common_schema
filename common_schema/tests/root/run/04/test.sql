SET @s := '{
  set @x := 3;
}
';

call run(@s);

SELECT @x = 3;

