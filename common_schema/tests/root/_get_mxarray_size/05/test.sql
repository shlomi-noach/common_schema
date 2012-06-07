select _create_mxarray() into @array_id;

select _push_mxarray_element(@array_id, 'abc') into @key1;
select _push_mxarray_element(@array_id, 'abc') into @key2;
select _create_mxarray() into @array_id2;

select _push_mxarray_element(@array_id2, 'd') into @key21;
select _push_mxarray_element(@array_id2, 'e') into @key22;
select _push_mxarray_element(@array_id2, 'f') into @key23;
select 
  _get_mxarray_size(@array_id) = 2
  and _get_mxarray_size(@array_id2) = 3
;
