--
-- Load and run QueryScript code from file
--

delimiter //

drop procedure if exists run_file //

create procedure run_file(
  in query_script_file_name text
)
comment 'Run given QueryScript file'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  call run(LOAD_FILE(query_script_file_name));
end;

//

delimiter ;
