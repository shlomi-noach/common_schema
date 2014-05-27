select _create_mxarray() into @array_id;

select 
  _implode_nospace_mxarray(@array_id) = ''
;
