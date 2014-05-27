call _create_array(@array_id);
call _set_array_element(@array_id, 'name', 'shushu');
call _push_array_element(@array_id, 'first');
call _get_array_element(@array_id, 1, @s);

SELECT @s = 'first';

