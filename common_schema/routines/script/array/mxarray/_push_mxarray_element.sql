--
--

delimiter //

drop function if exists _push_mxarray_element //

create function _push_mxarray_element(
   array_id int unsigned,
   element text charset utf8
) returns int unsigned

comment 'Pushes new element into array'
language SQL
deterministic
no sql
sql security invoker

main_body: begin
  declare array_max_key int unsigned;
  
  set array_max_key := _get_mxarray_max_key(array_id);
  set @_common_schema_mx_array := REPLACE(@_common_schema_mx_array, CONCAT('<maxkey aid="', array_id, '">'), CONCAT('<e key="', (array_max_key+1), '">', encode_xml(element), '</e><maxkey aid="', array_id, '">'));
  do _update_mxarray_max_key(array_id, (array_max_key+1));
  return array_id;
end;
//

delimiter ;
