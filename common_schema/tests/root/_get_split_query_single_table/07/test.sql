set @query := 'insert into test12.some_table values (1)';
call _interpret(@query, false);
call _get_split_query_single_table (
   1, 10000, @query_type_supported, @tables_found, @table_schema, @table_name
);

select 
  @query_type_supported = 0
  and @table_schema is null
  and @table_name is null;
