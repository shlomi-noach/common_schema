call rdebug_compile_routine('test_cs', 'dbg_iterate_numbers', true);
select 
    count(*) = 2 and 
    sum(variable_name in ('done', 'current_value')) = 2 
  from 
    _rdebug_routine_variables 
  where 
    routine_schema='test_cs'
    and routine_name='dbg_iterate_numbers';
