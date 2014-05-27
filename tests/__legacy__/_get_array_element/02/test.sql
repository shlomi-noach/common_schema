call _create_array(@array_id);
call _set_array_element(@array_id, 'name', 'shushu');
call _set_array_element(@array_id, 'age', '11');
call _get_array_element(@array_id, 'name', @name);
call _get_array_element(@array_id, 'age', @age);

SELECT @name = 'shushu' and @age = '11';

