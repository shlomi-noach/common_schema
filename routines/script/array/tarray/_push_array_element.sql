--
--

delimiter //

drop procedure if exists _push_array_element //

create procedure _push_array_element(
   in  array_id VARCHAR(16) charset ascii,
   in  element text charset utf8
) 
comment 'Pushes new element, key becomes incrementing number'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  declare exec_statement text default '';
  
  set exec_statement := CONCAT(
    'SELECT MAX(CAST(array_key AS UNSIGNED)) 
     FROM ', _get_array_name(array_id), ' INTO @_common_schema_push_array_max_val'); 
  call exec_single(exec_statement);
  
  set exec_statement := CONCAT(
    'INSERT INTO ', _get_array_name(array_id), ' 
       (array_key, value) 
     VALUES 
       (', IFNULL(@_common_schema_push_array_max_val + 1, 1), ', ', QUOTE(IFNULL(element, 'NULL')), ')');

  call exec_single(exec_statement);
end;
//

delimiter ;
