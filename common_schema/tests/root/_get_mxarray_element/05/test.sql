select _create_mxarray() into @array_id;

select _push_mxarray_element(@array_id, 'abc') into @key1;
select _push_mxarray_element(@array_id, 'abc') into @key2;
select _push_mxarray_element(@array_id, 'xyz') into @key3;

select _create_mxarray() into @array_id2;

select _push_mxarray_element(@array_id2, 'd') into @key21;
select _push_mxarray_element(@array_id2, 'e') into @key22;
select _push_mxarray_element(@array_id2, 'f') into @key23;
select 
  _get_mxarray_element(@array_id, @key1) = 'abc'
  and _get_mxarray_element(@array_id, @key2) = 'abc'
  and _get_mxarray_element(@array_id, @key3) = 'xyz'
  and _get_mxarray_element(@array_id2, @key21) = 'd'
  and _get_mxarray_element(@array_id2, @key22) = 'e'
  and _get_mxarray_element(@array_id2, @key23) = 'f'
;



