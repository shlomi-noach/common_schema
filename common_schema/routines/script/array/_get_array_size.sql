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
  select _get_mxarray_size(array_id) into array_size;
end;
//

delimiter ;
