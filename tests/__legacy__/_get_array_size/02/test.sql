call _create_array(@array_id);
call _set_array_element(@array_id, 'name', 'shushu');
call _push_array_element(@array_id, 'hello');

call _get_array_size(@array_id, @size);

SELECT @size = 2;

