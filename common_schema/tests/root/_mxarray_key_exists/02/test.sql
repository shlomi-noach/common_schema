select _create_mxarray() into @array_id;

select 
  _mxarray_key_exists(@array_id, 'mykey') = 0
;



