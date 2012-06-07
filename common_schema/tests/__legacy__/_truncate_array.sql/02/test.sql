call _create_array(@array_id);
call _push_array_element(@array_id, 'first');
call _push_array_element(@array_id, 'second');
call _get_array_size(@array_id, @size1);

call _truncate_array(@array_id);
call _get_array_size(@array_id, @size2);

select @size1 > 0 and @size2 = 0;

