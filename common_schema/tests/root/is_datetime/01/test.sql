SELECT 
  is_datetime(NOW()) 
  AND is_datetime(CURDATE())
  AND is_datetime(SYSDATE())
  AND is_datetime(DATE(NOW()))
;
