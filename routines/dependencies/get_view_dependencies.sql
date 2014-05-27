delimiter //

set names utf8
//

drop procedure if exists get_view_dependencies
//

create procedure get_view_dependencies (
    IN p_table_schema VARCHAR(64) CHARSET utf8
,   IN p_table_name VARCHAR(64) CHARSET utf8
)
DETERMINISTIC
READS SQL DATA

begin
    declare v_view_definition longtext charset utf8;
    declare exit handler for not found
        select concat('View `', p_table_schema, '`.`', p_table_name, '` not found.') error
    ; 
    
    select  view_definition
    into    v_view_definition
    from    information_schema.views
    where   table_schema = p_table_schema
    and     table_name = p_table_name;

    call get_sql_dependencies(v_view_definition, p_table_schema);
end
//

delimiter ;
