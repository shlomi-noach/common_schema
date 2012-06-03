--
--

delimiter //

drop function if exists _get_mxarray_max_key //

create function _get_mxarray_max_key(
   array_id int unsigned
) returns int unsigned
comment '(internal) get array''s current max key'
language SQL
deterministic
no sql
sql security invoker

main_body: begin
  return CAST(ExtractValue(@_common_schema_mx_array, CONCAT('/ma/a[@id="', array_id, '"]/maxkey')) AS UNSIGNED);
end;
//

delimiter ;
