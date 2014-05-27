SET @s := '
  set @i := 0;
  foreach ($i: 1:3)
    pass;
';
call run(@s);

SELECT 1;
