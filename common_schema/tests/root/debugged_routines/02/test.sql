call rdebug_compile_routine('test_cs', 'dbg_iterate_numbers', false);

select
    count(*) = 0
  from
    debugged_routines
  where 
    ROUTINE_SCHEMA = 'test_cs'
    and ROUTINE_NAME = 'dbg_iterate_numbers'
;