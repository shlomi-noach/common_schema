SET @s := '
  while (1)
  {
    input $a, $b;
    break;
  }
';
call run(@s);

