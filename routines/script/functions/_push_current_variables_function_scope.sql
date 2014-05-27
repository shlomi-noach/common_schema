--
--

delimiter //

drop procedure if exists _push_current_variables_function_scope //

create procedure _push_current_variables_function_scope(
	in  function_name varchar(64) charset ascii
) 
comment 'Push a function in the stack'
language SQL
deterministic
no sql
sql security invoker

main_body: begin
	set @_common_schema_script_function_scope := concat(function_name, ',', @_common_schema_script_function_scope);
end;
//

delimiter ;
