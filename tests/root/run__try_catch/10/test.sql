SET @s := '
  try {
    drop table test_cs._not_existing_table_;
  }
  catch {
    throw "will not get caught!";
  }
';
call run(@s);

select 1;