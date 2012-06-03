--
--

delimiter //

drop function if exists _update_mxarray_max_key //

create function _update_mxarray_max_key(
   array_id int unsigned,
   array_max_key int unsigned
) returns int unsigned

comment '(internal) updated max-key indicator'
language SQL
deterministic
no sql
sql security invoker

main_body: begin
  set @_common_schema_mx_array := UpdateXML(@_common_schema_mx_array, CONCAT('/ma/a[@id="', array_id, '"]/maxkey'), CONCAT('<maxkey aid="', array_id, '">', array_max_key, '</maxkey>'));
  return array_id;
end;
//

delimiter ;
