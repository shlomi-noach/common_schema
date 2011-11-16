delimiter //

set names utf8
//

drop procedure if exists get_event_dependencies
//

create procedure get_event_dependencies (
    IN p_event_schema VARCHAR(64) CHARSET utf8 
,   IN p_event_name VARCHAR(64) CHARSET utf8
)
DETERMINISTIC
READS SQL DATA

begin
    declare v_event_definition longtext charset utf8;
    declare exit handler for not found
        select concat('Event `', p_event_schema, '`.`', p_event_name, '` not found.') error
    ; 
    
    select  body
    into    v_event_definition
    from    mysql.event
    where   db      = p_event_schema
    and     name    = p_event_name;

    call get_sql_dependencies(v_event_definition, p_event_schema);
end
//

delimiter ;
