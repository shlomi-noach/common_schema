SET @s := '
  try {
    set @res := 11;
    drop table test_cs._not_existing_table_;
    set @res := 13;
  }
  catch {
  }
';
call run(@s);

select @res = 11;
