--
--

delimiter //

drop function if exists _create_mxarray //

create function _create_mxarray()
returns int unsigned

comment 'Creates an array, returning its ID'
language SQL
deterministic
no sql
sql security invoker

main_body: begin
  if @_common_schema_mx_array IS NULL then
    set @_common_schema_mx_array := '<ma></ma>';
  end if;
  
  set @_common_schema_create_mxarray_id := session_unique_id();
  set @_common_schema_mx_array := REPLACE(@_common_schema_mx_array, '</ma>', CONCAT('<a id="', @_common_schema_create_mxarray_id, '"><maxkey aid="', @_common_schema_create_mxarray_id, '">0</maxkey></a></ma>'));
  return @_common_schema_create_mxarray_id;
end;
//

delimiter ;
