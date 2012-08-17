SET @s := '
  try {
    set @res := 11;
    throw "aborting try block";
    set @res := 13;
  }
  catch {
    set @res := @res - 1;
  }
';
call run(@s);

select @res = 10;
