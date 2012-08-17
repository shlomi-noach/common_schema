update test_cs.test_split set nval = 23;
update test_cs.test_split_sparse set nval = 0;
set @counter := 0;
SET @s := '
  split(update test_cs.test_split join test_cs.test_split_sparse using(id) 
          set test_cs.test_split_sparse.nval = test_cs.test_split.nval + 1)
  {
    set @counter := @counter + 1;
  }
  ';
call run(@s);

