call rdebug_compile_routine('test_cs', 'dbg_iterate_numbers', true);
select 
    group_concat(id order by id) 
  from _routine_tokens 
  where is_valid_for_breakpoint 
  into @_routine_tokens_breakpoint_ids;
select 
    group_concat(statement_id order by statement_id) 
  from _rdebug_routine_statements 
  where 
    routine_schema='test_cs' 
    and routine_name='dbg_iterate_numbers' 
  into @_routine_statements_breakpoint_ids;
select @_routine_tokens_breakpoint_ids = @_routine_statements_breakpoint_ids;
