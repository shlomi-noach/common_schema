call _create_array(@array_id);
call _concatenate_array_elements(@array_id, '-', @result);

select @result IS NULL;

