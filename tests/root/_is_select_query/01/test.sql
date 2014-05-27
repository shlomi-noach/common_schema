SELECT 
  _is_select_query('SELECT 3') = 1
  AND _is_select_query('select 3') = 1
  AND _is_select_query('  SELECT 3') = 1
;
