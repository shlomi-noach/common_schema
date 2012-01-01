call _create_array(@array_id);
call _push_array_element(@array_id, 'shushu');
call _get_array_element(@array_id, 1, @s);

SELECT @s = 'shushu';

