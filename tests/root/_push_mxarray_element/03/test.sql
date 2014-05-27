select _create_mxarray() into @array_id;

select _push_mxarray_element(@array_id, 'abc') into @dummy;
select _push_mxarray_element(@array_id, 'abc') into @dummy;
select _push_mxarray_element(@array_id, 'xyz') into @dummy;

select _get_mxarray_size(@array_id) = 3;
