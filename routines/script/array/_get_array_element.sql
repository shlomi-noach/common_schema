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
  set @_element=null;
  select _get_mxarray_element(array_id, array_key) into @_element;
  set element=@_element;
end;
//

delimiter ;
