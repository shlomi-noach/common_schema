call _create_array(@array_id);
call _push_array_element(@array_id, 'x');
set @s := CONCAT('SELECT value FROM ', _get_array_name(@array_id), ' WHERE array_key = 1 INTO @val');
call exec_single(@s);
SELECT @val = 'x';
