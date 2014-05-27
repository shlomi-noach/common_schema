SELECT 
  _is_select_query('UPDATE t SET id=3') = 0
  AND _is_select_query('SHOW TABLES') = 0
  AND _is_select_query('124') = 0
;
