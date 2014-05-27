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
  do _push_mxarray_element(array_id, element);
end;
//

delimiter ;
