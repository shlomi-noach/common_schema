--
--

delimiter //

drop procedure if exists _drop_mxarray //

create procedure _drop_mxarray(
   in  array_id int unsigned
) 
comment 'Drops an array'
language SQL
deterministic
no sql
sql security invoker

main_body: begin
  set @_common_schema_mx_array := UpdateXML(@_common_schema_mx_array, CONCAT('/ma/a[@id="', array_id, '"]'), '');
end;
//

delimiter ;
