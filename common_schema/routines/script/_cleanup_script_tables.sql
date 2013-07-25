--
--
--

delimiter //

drop procedure if exists _cleanup_script_tables//

create procedure _cleanup_script_tables()
comment '...'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  if not (@query_script_skip_cleanup is true) then
    delete from _sql_tokens;
    delete from _qs_variables;
    delete from _script_report_data;
    delete from _split_column_names_table;
  end if;
end;
//

delimiter ;
