call _create_array(@array_id);
call _set_array_element(@array_id, 'name', 'shushu');
call _set_array_element(@array_id, '17', 'numeric');
call _push_array_element(@array_id, 'found');
call _get_array_element(@array_id, 18, @s);

SELECT @s = 'found';

