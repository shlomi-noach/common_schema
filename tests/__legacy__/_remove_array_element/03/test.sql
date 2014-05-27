call _create_array(@array_id);
call _set_array_element(@array_id, 'name', 'shushu');
call _set_array_element(@array_id, 'age', '11');
call _remove_array_element(@array_id, 'age');
set @s := CONCAT('SELECT COUNT(*) FROM ', _get_array_name(@array_id), ' WHERE value = ''shushu'' INTO @c');
call exec_single(@s);
set @s := CONCAT('SELECT COUNT(*) FROM ', _get_array_name(@array_id), ' WHERE value = ''age'' INTO @c_age');
call exec_single(@s);
SELECT @c = 1 and @c_age = 0;
