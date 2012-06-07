--
--

delimiter //

drop function if exists _mxarray_key_exists //

create function _mxarray_key_exists(
   array_id int unsigned,
   array_key varchar(127) charset utf8
) returns tinyint unsigned
comment 'Check whether key exists within array'
language SQL
deterministic
no sql
sql security invoker

main_body: begin
  return (IFNULL(ExtractValue(@_common_schema_mx_array, CONCAT('count(/ma/a[@id="', array_id, '"]/e[@key="', encode_xml(array_key), '"][1])')), 0) > 0);
end;
//

delimiter ;
