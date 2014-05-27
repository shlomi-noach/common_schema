--
-- We assume the array elements do not contain spaces
--

delimiter //

drop function if exists _implode_nospace_mxarray //

create function _implode_nospace_mxarray(
   array_id int unsigned
) returns text charset utf8

comment 'Return array elements concatenated by commas'
language SQL
deterministic
no sql
sql security invoker

main_body: begin
  return replace(
    IFNULL(
      ExtractValue(@_common_schema_mx_array, CONCAT('/ma/a[@id="', array_id, '"]/e')), 
      '')
    , ' ', ','
    );
end;
//

delimiter ;
