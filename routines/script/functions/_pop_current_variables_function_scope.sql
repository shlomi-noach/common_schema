--
--

delimiter //

drop procedure if exists _pop_current_variables_function_scope //

create procedure _pop_current_variables_function_scope() 
comment 'Push a function in the stack'
language SQL
deterministic
no sql
sql security invoker

main_body: begin
	set @_common_schema_script_function_scope := SUBSTRING(
		@_common_schema_script_function_scope,
		LOCATE(',', @_common_schema_script_function_scope) + 1
	);
end;
//

delimiter ;
