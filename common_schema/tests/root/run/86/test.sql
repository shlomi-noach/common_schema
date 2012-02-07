SET @s := '
  set @x := 0;
  foreach($a: 1:10)
  {
    set @x := $a;
    if ($a = 7)
      break;
  }
';
call run(@s);
select @x = 7;
