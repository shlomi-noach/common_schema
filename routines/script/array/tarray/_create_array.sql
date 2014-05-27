--
--

delimiter //

drop procedure if exists _create_array //

create procedure _create_array(
   out  array_id VARCHAR(16) charset ascii
) 
comment 'Creates an array, returning its ID'
language SQL
deterministic
modifies sql data
sql security invoker

main_body: begin
  declare exec_statement text default '';
  
  set array_id := session_unique_id();
  set exec_statement := CONCAT(
    'CREATE TEMPORARY TABLE ', _get_array_name(array_id), '(
       array_key varchar(127) charset utf8 PRIMARY KEY,
       value text charset utf8
     )'); 

  call exec_single(exec_statement);
end;
//

delimiter ;
