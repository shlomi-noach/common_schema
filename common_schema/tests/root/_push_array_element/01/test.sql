call _create_array(@array_id);
call _push_array_element(@array_id, 'x');
set @s := CONCAT('SELECT COUNT(*) FROM ', _get_array_name(@array_id), ' INTO @c');
call exec_single(@s);
SELECT @c = 1;

