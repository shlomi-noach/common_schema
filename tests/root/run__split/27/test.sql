
SET @s := '
  split(replace into test_cs.test_split_twin select * from test_cs.test_split where id % 100 = 0)
  {
    set @table_schema := $split_table_schema; 
    set @table_name := $split_table_name;
    break; 
  }
  ';
call run(@s);

select @table_schema = 'test_cs' and @table_name = 'test_split';