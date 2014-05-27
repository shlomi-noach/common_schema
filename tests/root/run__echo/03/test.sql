
SET @s := '
  set @x := 3;
  echo SELECT @x, ''abc'' FROM DUAL
  ';
call run(@s);

