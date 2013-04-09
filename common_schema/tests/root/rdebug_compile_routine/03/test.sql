call rdebug_compile_routine('test_cs', 'dbg_iterate_numbers', true);
select body from mysql.proc where db='test_cs' and name='dbg_iterate_numbers' into @body;
select locate(_rdebug_get_debug_code_start(), @body) > 0;
