call _create_array(@array_id);
call _push_array_element(@array_id, 'one');
call _concatenate_array_elements(@array_id, '-', @result);

select @result = 'one';

