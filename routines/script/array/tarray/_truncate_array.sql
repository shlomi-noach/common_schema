--
--

delimiter //

drop procedure if exists _truncate_array //

create procedure _truncate_array(
   in  array_id VARCHAR(16) charset ascii
) 
comment 'Truncates an array'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  declare exec_statement text default '';
  
  set exec_statement := CONCAT(
    'TRUNCATE ', _get_array_name(array_id), '');

  call exec_single(exec_statement);
end;
//

delimiter ;
