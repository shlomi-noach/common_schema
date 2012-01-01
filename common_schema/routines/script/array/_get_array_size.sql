--
--

delimiter //

drop procedure if exists _get_array_size //

create procedure _get_array_size(
   in  array_id VARCHAR(16) charset ascii,
   out array_size int unsigned
) 
comment 'Creates an array, returning its ID'
language SQL
deterministic
reads sql data
sql security invoker

main_body: begin
  declare exec_statement text default '';
  
  set @_common_schema_get_array_size_result := NULL;
  set exec_statement := CONCAT(
    'SELECT COUNT(*) FROM ', _get_array_name(array_id), ' INTO @_common_schema_get_array_size_result');

  call exec_single(exec_statement);
  set array_size := @_common_schema_get_array_size_result;  
end;
//

delimiter ;
