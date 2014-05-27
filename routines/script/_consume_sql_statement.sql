--
--
--

delimiter //

drop procedure if exists _consume_sql_statement //

create procedure _consume_sql_statement(
   in   id_from      int unsigned,
   in   statement_id_to      int unsigned,
   in   should_execute_statement tinyint unsigned
)
comment 'Consumes & executes SQL statement'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  declare mysql_statement TEXT CHARSET utf8;
  
  -- Construct the original statement, send it for execution.
  call _expand_statement_variables(id_from, statement_id_to, mysql_statement, @_common_schema_dummy, should_execute_statement);
  if should_execute_statement then
    call exec_single(mysql_statement);
    set @query_script_rowcount := @common_schema_rowcount;
    set @query_script_found_rows := @common_schema_found_rows;
  end if;
end;
//

delimiter ;
