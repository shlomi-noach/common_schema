select _create_mxarray() into @array_id;

set @s := '3 > "2" & 4 < 5';
select _push_mxarray_element(@array_id, @s) into @key;
select _get_mxarray_element(@array_id, @key) = @s;

