SET @s := '
  truncate test_cs.test_run_transaction;
  start transaction;
  insert into test_cs.test_run_transaction select n from numbers where n between 1 and 4;
  select count(*) from test_cs.test_run_transaction into @count_inside;
  rollback;
  select count(*) from test_cs.test_run_transaction into @count;
';
call run(@s);

select @count_inside = 4 and @count = 0;
