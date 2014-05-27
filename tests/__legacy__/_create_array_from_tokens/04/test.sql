call _create_array_from_tokens('the,quick,brown,fox', ',', @array_id);
call _concatenate_array_elements(@array_id, '-', @result);

select @result = 'the-quick-brown-fox';

