SET @s := '
  try {
    set @res := 11;
    try {
      drop table test_cs._not_existing_table_;
      set @res := 29;
    }
    catch {
      set @res := @res-1;
    }
  }
  catch {
    set @res := 43;
  }
';
call run(@s);

select @res = 10;