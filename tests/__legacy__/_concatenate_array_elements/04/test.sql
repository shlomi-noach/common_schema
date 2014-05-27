call _create_array(@array_id);
call _set_array_element(@array_id, 'name', 'shushu');
call _set_array_element(@array_id, 'age', '11');
call _set_array_element(@array_id, 'id', '12345');
call _concatenate_array_elements(@array_id, '-', @result);

select @result = '11-12345-shushu';


