SET @s := '
  set @res := 17;
  if (@res < 3)
    pass;
  else {
    set @res := 29;
  }
';
call run(@s);

select @res = 29;
