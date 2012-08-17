--
--

delimiter //

drop procedure if exists _load_array_into_table //

create procedure _load_array_into_table(
   in  array_id VARCHAR(16) charset ascii,
   in  full_table_name VARCHAR(128) charset utf8
) 
comment 'Dumps elements of array'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  declare exec_statement text default '';
  
  set exec_statement := CONCAT(
    'INSERT INTO ', full_table_name, 
    ' SELECT * FROM ', _get_array_name(array_id), '');

  call exec_single(exec_statement);
end;
//

delimiter ;
