select _create_mxarray() into @array_id;

select 
  _push_mxarray_element(@array_id, 'abc')  = 1
  and _push_mxarray_element(@array_id, 'abc')  = 2
  and _push_mxarray_element(@array_id, 'xyz')  = 3
;

