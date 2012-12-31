--
--
--

delimiter //

drop function if exists extract_json_value//

create function extract_json_value(
    json_text text charset utf8,
    xpath text
) returns text charset utf8
comment 'Extracts JSON value via XPath'
language SQL
deterministic
modifies sql data
sql security invoker
begin
  return ExtractValue(json_to_xml(json_text), xpath);	
end;
//

delimiter ;
