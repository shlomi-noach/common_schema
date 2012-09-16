SELECT 
  not is_datetime('2012-09-150') 
  AND not is_datetime('2012-09-1501:23:45')
  AND not is_datetime('20120966')
  AND not is_datetime('20120915012377')
;
