SET @s := '
  try {
    set @res := 16;
    set @res := @res + 1;
  }
  catch {
    set @res := 0;
  }
';
call run(@s);

select @res = 17;
