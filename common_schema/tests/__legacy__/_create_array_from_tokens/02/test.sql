call _create_array_from_tokens(NULL, ',', @array_id);

call _get_array_size(@array_id, @size);

select @size = 0;

