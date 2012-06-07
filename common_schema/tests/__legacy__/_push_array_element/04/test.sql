call _create_array(@array_id);
call _push_array_element(@array_id, 'x');
call _push_array_element(@array_id, 'y');
set @s := CONCAT('SELECT GROUP_CONCAT(array_key) FROM ', _get_array_name(@array_id), ' INTO @keys');
call exec_single(@s);
SELECT @keys = '1,2';
