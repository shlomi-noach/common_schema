select _create_mxarray() into @array_id;

select _push_mxarray_element(@array_id, 'abc') = @array_id;

