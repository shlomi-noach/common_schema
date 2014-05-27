select _create_mxarray() into @array_id;

select 
  _get_mxarray_element(@array_id, 'mykey') is null
;

