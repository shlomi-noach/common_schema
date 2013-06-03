set @result = '';
SET @s := '
  split(test_cs.test_split_multiple_unique)
  {
    select $split_index into @result;
    return;
  }
  ';
call run(@s);

select @result = 'PRIMARY';
