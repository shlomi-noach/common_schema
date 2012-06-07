select _create_mxarray() into @array_id;

select 
  _push_mxarray_element(@array_id, 'abc') is not null
  and _push_mxarray_element(@array_id, 'abc') is not null
  and _push_mxarray_element(@array_id, 'xyz') is not null
;

