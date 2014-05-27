
delimiter //

set names utf8
//

drop procedure if exists get_sql_dependencies
//

create procedure get_sql_dependencies(
    IN p_sql               TEXT charset utf8
,   IN p_default_schema    VARCHAR(64) charset utf8
)
DETERMINISTIC

my_main: begin
	call _get_sql_dependencies_internal(p_sql, p_default_schema, 1, @_common_schema_result_success);
end;
//

delimiter ;

