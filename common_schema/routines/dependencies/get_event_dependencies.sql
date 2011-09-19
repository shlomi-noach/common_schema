delimiter //

set names utf8
//

drop procedure if exists get_event_dependencies
//

create procedure get_event_dependencies (
    in  p_event_schema varchar(64) charset utf8 
,   in  p_event_name varchar(64) charset utf8
)
begin
    declare v_event_definition longtext charset utf8;
    declare exit handler for not found
        select concat('Event `', p_event_schema, '`.`', p_event_name, '` not found.') error
    ; 
    
    select  body
    into    v_event_definition
    from    mysql.event
    where   db      = p_eventt_schema
    and     name    = p_event_name;

    call get_sql_dependencies(v_event_definition, p_event_schema);
end
//

delimiter ;
