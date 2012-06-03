--
--

delimiter //

drop function if exists _mxrray_key_exists //

create function _mxrray_key_exists(
   array_id int unsigned,
   array_key varchar(127) charset utf8
) returns tinyint unsigned
comment 'Check whether key exists within array'
language SQL
deterministic
no sql
sql security invoker

main_body: begin
  return (ExtractValue(@_common_schema_mx_array, CONCAT('count(/ma/a[@id="', array_id, '"]/e[@key="', encode_xml(array_key), '"][1])')) IS NOT NULL);
end;
//

delimiter ;
