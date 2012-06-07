select _create_mxarray() into @array_id;

select _push_mxarray_element(@array_id, 'abc') into @key;
select _mxarray_key_exists(@array_id, @key) = 1;

