delimiter //

set names utf8
//

drop procedure if exists get_routine_dependencies
//

create procedure get_routine_dependencies (
    in  p_routine_schema varchar(64) charset utf8 
,   in  p_routine_name varchar(64) charset utf8
)
begin
    declare v_routine_definition longtext charset utf8;
    declare exit handler for not found
        select concat('Routine `', p_routine_schema, '`.`', p_routine_name, '` not found.') error
    ; 
    
    select  body
    into    v_routine_definition
    from    mysql.proc
    where   db      = p_routine_schema
    and     name    = p_routine_name;

    call get_sql_dependencies(v_routine_definition, p_routine_schema);
end
//

delimiter ;
