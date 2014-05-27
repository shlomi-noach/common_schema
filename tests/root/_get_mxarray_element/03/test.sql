select _create_mxarray() into @array_id;

select _push_mxarray_element(@array_id, 'abc') into @key;
select _get_mxarray_element(@array_id, @key) = 'abc';

