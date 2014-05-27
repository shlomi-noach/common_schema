select _create_mxarray() into @array_id;
select _create_mxarray() into @array_id2;

select _push_mxarray_element(@array_id, 'abc') into @key1;

select _drop_mxarray(@array_id2) into @dummy;

select _get_mxarray_element(@array_id, @key1) = 'abc';

