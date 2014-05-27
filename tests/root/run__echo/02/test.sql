
SET @s := '
  echo SELECT 1, ''abc'' FROM DUAL
  ';
call run(@s);

