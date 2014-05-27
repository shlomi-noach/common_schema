SET @s := '
  set @res := 17;
  try {
    start slave;
    stop slave;
  }
  catch {
    set @res := 43;
  }
';
call run(@s);

select @res in (17, 43);
