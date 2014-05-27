SELECT 
  not is_datetime(3) 
  AND not is_datetime('4')
  AND not is_datetime('abc')
  AND not is_datetime(20.3)
;
