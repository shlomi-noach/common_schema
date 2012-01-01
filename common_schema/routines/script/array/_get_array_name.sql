--
--

delimiter //

drop function if exists _get_array_name //

create function _get_array_name(
   array_id VARCHAR(16) charset ascii
) returns VARCHAR(64) charset utf8
comment 'Returning internal array name by id'
language SQL
deterministic
no sql
sql security invoker

begin
  return CONCAT('_qs_array_', array_id);
end;
//

delimiter ;
