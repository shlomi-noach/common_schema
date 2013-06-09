call rdebug_compile_routine('test_cs', 'dbg_iterate_numbers', true);

select
    count(*) = 1
  from
    debugged_routines
  where 
    ROUTINE_SCHEMA = 'test_cs'
    and ROUTINE_NAME = 'dbg_iterate_numbers'
;