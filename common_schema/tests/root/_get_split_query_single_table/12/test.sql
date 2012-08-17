set @query := 'update test.t1 STRAIGHT_JOIN test.t2 set val = val + 1';
call _interpret(@query, false);
call _get_split_query_single_table (
   1, 10000, @query_type_supported, @tables_found, @table_schema, @table_name
);

select 
  @query_type_supported = 1
  and @tables_found = 'multi' 
  and @table_schema is null
  and @table_name is null;
