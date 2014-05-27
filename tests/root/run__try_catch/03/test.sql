SET @s := '
  try {
    set @res := 17;
  }
';
call run(@s);

select 1;