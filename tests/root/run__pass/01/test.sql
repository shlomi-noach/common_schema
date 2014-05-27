SET @s := '
  pass;
  if (2 < 3)
    pass;
';
call run(@s);

select 1;
