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
  declare xpath varchar(64) charset utf8;
  if array_id is null then
    return null;
  end if;
  set xpath := CONCAT('/ma/a[@id="', array_id, '"]');
  set @_common_schema_mx_array := UpdateXML(@_common_schema_mx_array, xpath, '');
  return array_id;
end;
//

delimiter ;
