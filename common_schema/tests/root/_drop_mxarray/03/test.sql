select _create_mxarray() into @array_id;

select _push_mxarray_element(@array_id, 'abc') into @key1;
select _get_mxarray_element(@array_id, @key1) into @element;

select _drop_mxarray(@array_id) into @dummy;

select _get_mxarray_element(@array_id, @key1) into @element_dropped;

select @element = 'abc' and @element_dropped is null;

