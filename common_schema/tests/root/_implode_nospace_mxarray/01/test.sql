select _create_mxarray() into @array_id;

select _push_mxarray_element(@array_id, 'a') into @key1;
select _push_mxarray_element(@array_id, '$b') into @key2;
select _push_mxarray_element(@array_id, 'c') into @key2;

select 
  _implode_nospace_mxarray(@array_id) = 'a,$b,c'
;
