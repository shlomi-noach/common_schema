SELECT 
  shorttime_to_seconds(12) IS NULL
  AND shorttime_to_seconds('abc') IS NULL
  AND shorttime_to_seconds(NULL) IS NULL
  ;
