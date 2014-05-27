--
--

delimiter //

drop procedure if exists _drop_array //

create procedure _drop_array(
   in  array_id int unsigned
) 
comment 'Drops an array'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  select _drop_mxarray(array_id) into @_common_schema_dummy;
end;
//

delimiter ;
