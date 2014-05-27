call _create_array(@array_id);
call _set_array_element(@array_id, 'name', 'shushu');
set @s := CONCAT('SELECT value FROM ', _get_array_name(@array_id), ' WHERE array_key = ''name'' INTO @val');
call exec_single(@s);
SELECT @val = 'shushu';
