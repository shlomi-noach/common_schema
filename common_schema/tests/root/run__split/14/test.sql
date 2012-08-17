update test_cs.test_split set nval = 23;
update test_cs.test_split_sparse set nval = 0;
SET @s := '
  split(test_cs.test_split: 
          update test_cs.test_split join test_cs.test_split_sparse using(id) 
          set test_cs.test_split_sparse.nval = test_cs.test_split.nval + 1)
  {
  }
  ';
call run(@s);

select distinct nval = 24 from test_cs.test_split_sparse;
