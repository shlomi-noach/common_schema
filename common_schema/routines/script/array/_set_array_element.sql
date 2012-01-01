--
--

delimiter //

drop procedure if exists _set_array_element //

create procedure _set_array_element(
   in  array_id VARCHAR(16) charset ascii,
   in array_key varchar(127) charset utf8,
   in element text charset utf8
) 
comment 'Sets an element based on key'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  declare exec_statement text default '';
  
  set exec_statement := CONCAT(
    'INSERT INTO ', _get_array_name(array_id), ' 
       (array_key, value) 
     VALUES 
       (', QUOTE(array_key), ',', QUOTE(element), ')
     ON DUPLICATE KEY UPDATE value = VALUES(value)
  ');

  call exec_single(exec_statement);
end;
//

delimiter ;
