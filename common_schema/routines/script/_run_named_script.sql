--
-- Run script from _named_scripts table
--

delimiter //

drop procedure if exists _run_named_script //

create procedure _run_named_script(
  named_script_name varchar(64) CHARACTER SET ascii
)
comment 'Run script from _named_scripts table'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  declare query_script text charset utf8;
  
  select script_text from _named_scripts where script_name = named_script_name into query_script;
  if query_script is null then
    call throw(CONCAT('Unknown script: ', named_script_name));
  end if;
  call run(query_script);
end;

//

delimiter ;
