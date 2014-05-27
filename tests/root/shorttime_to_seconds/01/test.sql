SELECT 
  shorttime_to_seconds('10s') = 10
  AND shorttime_to_seconds('3m') = 180
  AND shorttime_to_seconds('2h') = 7200
  ;
