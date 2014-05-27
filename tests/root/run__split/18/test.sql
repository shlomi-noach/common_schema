set @counter := 0;
SET @s := '
  split(test_cs.test_split_sparse: 
          delete from test_cs.test_split_twin 
          using test_cs.test_split_twin join test_cs.test_split_sparse using(id) 
       )
  {
  }
  ';
call run(@s);


select count(*) = 3996 from test_cs.test_split_twin;