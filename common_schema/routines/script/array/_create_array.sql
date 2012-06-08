--
--

delimiter //

drop procedure if exists _create_array //

create procedure _create_array(
   out  array_id VARCHAR(16) charset ascii
) 
comment 'Creates an array, returning its ID'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  select _create_mxarray() into array_id;
end;
//

delimiter ;
