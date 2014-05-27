--
-- It is assumed input array elements do not contain spaces.
--

delimiter //

drop function if exists _implode_nospace_array //

create function _implode_nospace_array(
   array_id VARCHAR(16) charset ascii
) returns text charset utf8

comment 'Return array elements concatenated by commas'
language SQL
deterministic
no sql
sql security invoker

main_body: begin
  return _implode_nospace_mxarray(array_id);
end;
//

delimiter ;
