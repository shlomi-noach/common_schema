SET @s := '
  truncate test_cs.test_run_transaction;
  start transaction;
  insert into test_cs.test_run_transaction select n from numbers where n between 1 and 4;
  rollback;
  select count(*) from test_cs.test_run_transaction into @count;
';
call run(@s);

select @count = 0;
