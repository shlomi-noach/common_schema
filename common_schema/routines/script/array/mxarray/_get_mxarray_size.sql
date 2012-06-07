--
--

delimiter //

drop function if exists _get_mxarray_size //

create function _get_mxarray_size(
   array_id int unsigned
) returns int unsigned

comment 'Return number of elements in indicated array'
language SQL
deterministic
no sql
sql security invoker

main_body: begin
  return CAST(IFNULL(ExtractValue(@_common_schema_mx_array, CONCAT('count(/ma/a[@id="', array_id, '"]/e)')), 0) AS UNSIGNED);
end;
//

delimiter ;
