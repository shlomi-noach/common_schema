call rdebug_compile_routine('test_cs', 'dbg_iterate_numbers', true);
select count(*) = 10 from _routine_tokens where is_valid_for_breakpoint;
