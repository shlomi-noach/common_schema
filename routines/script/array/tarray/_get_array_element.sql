--
--

delimiter //

drop procedure if exists _get_array_element //

create procedure _get_array_element(
   in  array_id VARCHAR(16) charset ascii,
   in array_key varchar(127) charset utf8,
   out element text charset utf8
) 
comment 'Creates an array, returning its ID'
language SQL
deterministic
reads sql data
sql security invoker

main_body: begin
  declare exec_statement text default '';
  
  set @_common_schema_get_array_element_value := NULL;
  set exec_statement := CONCAT(
    'SELECT value FROM ', _get_array_name(array_id), ' 
       WHERE array_key = ', IFNULL(QUOTE(array_key), 'NULL'), ' INTO @_common_schema_get_array_element_value');

  call exec_single(exec_statement);
  set element := @_common_schema_get_array_element_value;  
end;
//

delimiter ;
