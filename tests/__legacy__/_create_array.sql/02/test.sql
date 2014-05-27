call _create_array(@array_id);

set @s := CONCAT('SELECT COUNT(*) FROM ', _get_array_name(@array_id), ' INTO @c');
call exec_single(@s);
SELECT @c = 0;
