SET @s := '
  set @x := 3;
  set @x := @x + 1;  
';

call run(@s);

SELECT @x = 4;
