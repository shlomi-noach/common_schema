SELECT 
  like_to_rlike('mysql%') = '^mysql.*$'
  AND like_to_rlike('c_oun%') = '^c.oun.*$'
  AND like_to_rlike('simple') = '^simple$'
;
