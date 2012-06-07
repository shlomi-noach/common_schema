select _create_mxarray() into @array_id;

select _push_mxarray_element(@array_id, 'abc') into @key1;
select _push_mxarray_element(@array_id, 'abc') into @key2;
select _push_mxarray_element(@array_id, 'xyz') into @key3;
select 
  _get_mxarray_element(@array_id, @key1) = 'abc'
  and _get_mxarray_element(@array_id, @key2) = 'abc'
  and _get_mxarray_element(@array_id, @key3) = 'xyz'
;

