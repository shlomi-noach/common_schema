--
--

delimiter //

drop procedure if exists _dump_array //

create procedure _dump_array(
   in  array_id VARCHAR(16) charset ascii
) 
comment 'Dumps elements of array'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  declare exec_statement text default '';
  
  set exec_statement := CONCAT(
    'SELECT * FROM ', _get_array_name(array_id), '');

  call exec_single(exec_statement);
end;
//

delimiter ;
