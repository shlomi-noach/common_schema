--
--

delimiter //

drop procedure if exists _concatenate_array_elements //

create procedure _concatenate_array_elements(
   in  array_id VARCHAR(16) charset ascii,
   in   delimiter text charset utf8,
   out   result text charset utf8
) 
comment 'Creates a populated array, returning its ID'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  declare exec_statement text default '';
  
  set @_common_schema_get_array_element_value := NULL;
  set exec_statement := CONCAT(
    'SELECT GROUP_CONCAT(value ORDER BY array_key SEPARATOR ''', delimiter ,''') FROM ', _get_array_name(array_id), 
       ' INTO @_common_schema_concatenate_array_elements_value');

  call exec_single(exec_statement);
  set result := @_common_schema_concatenate_array_elements_value;  
end;
//

delimiter ;
