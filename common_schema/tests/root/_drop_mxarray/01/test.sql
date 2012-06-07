select _drop_mxarray(_create_mxarray()) into @array_id;

select @array_id >= 0;
