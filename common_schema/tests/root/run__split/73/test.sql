
SET @s := '
  set @chosen_index := NULL;
  split({table: test_cs.test_split_multiple_unique, index: non_unique_idx})
  {
    set @chosen_index := $split_index;
  }
  ';
call run(@s);

select @chosen_index = 'non_unique_idx';

