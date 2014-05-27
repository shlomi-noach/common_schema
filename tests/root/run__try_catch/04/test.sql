SET @s := '
  try {
    set @res := 17;
  }
  catch {
  }
  catch {
  }
';
call run(@s);

select 1;