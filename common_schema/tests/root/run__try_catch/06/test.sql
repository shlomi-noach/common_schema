SET @s := '
  try {
    set @res := 11;
    drop table test_cs._not_existing_table_;
  }
  catch {
    set @res := 17;
  }
';
call run(@s);

select @res = 17;
