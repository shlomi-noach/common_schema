--
--
--

delimiter //

drop procedure if exists _throw_script_error //

create procedure _throw_script_error(
   in id_from      int unsigned,
   in message varchar(1024) charset utf8
)
comment 'Raises error and quites from script'
language SQL
deterministic
reads sql data
sql security invoker

main_body: begin
    declare full_message varchar(2048);
    declare error_pos int unsigned;

    SELECT LEFT(GROUP_CONCAT(token ORDER BY id SEPARATOR ''), 80), SUBSTRING_INDEX(GROUP_CONCAT(start ORDER BY id), ',', 1) FROM _sql_tokens WHERE id >= id_from INTO full_message, error_pos;
    
    set full_message := CONCAT('QueryScript error: [', message, '] at ', error_pos, ': "', full_message, '"');
    call throw(full_message);
end;
//

delimiter ;
