--
--

delimiter //

drop function if exists _drop_mxarray //

create function _drop_mxarray(
   array_id int unsigned
) returns int unsigned
comment 'Drops an array'
language SQL
deterministic
no sql
sql security invoker

main_body: begin
  set @_common_schema_mx_array := UpdateXML(@_common_schema_mx_array, CONCAT('/ma/a[@id="', array_id, '"]'), '');
  return array_id;
end;
//

delimiter ;
