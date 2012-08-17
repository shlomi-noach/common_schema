SET @s := '
  while (true)
  {
    var $a := 3;
    set @res := $a;
    break;
  }
';
call run(@s);

select @res = 3;
