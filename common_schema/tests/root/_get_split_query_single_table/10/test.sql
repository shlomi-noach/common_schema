set @query_script_skip_cleanup := true;
set @query := 'update `test`.some_table2 set val = val+1';
call _interpret(@query, false);
call _get_split_query_single_table (
   1, 10000, @query_type_supported, @tables_found, @table_schema, @table_name
);

select 
  @query_type_supported = 1
  and @tables_found = 'single' 
  and @table_schema = 'test'
  and @table_name = 'some_table2';
