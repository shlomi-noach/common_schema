--
--

delimiter //

drop procedure if exists _drop_array //

create procedure _drop_array(
   in  array_id VARCHAR(16) charset ascii
) 
comment 'Drops an array'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  declare exec_statement text default '';
  
  set exec_statement := CONCAT(
    'DROP TEMPORARY TABLE IF EXISTS ', _get_array_name(array_id), '');

  call exec_single(exec_statement);
end;
//

delimiter ;
