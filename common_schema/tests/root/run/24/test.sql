SET @s := '{
  /* set @x := 4; */
  set @x := 3;
  /* set @x := @x + 1; */
}
';

call run(@s);

SELECT @x = 3;

