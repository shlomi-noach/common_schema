SET @s := '
  try {
    set @res := 17;
  }
  catch {
    set @res := 0;
  }
';
call run(@s);

select @res = 17;
