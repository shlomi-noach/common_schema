call _create_array(@array_id);
call _get_array_element(@array_id, 'name', @name);

SELECT @name IS NULL;

