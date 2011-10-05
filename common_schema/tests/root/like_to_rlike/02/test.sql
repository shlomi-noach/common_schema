SELECT 
  like_to_rlike('10.0.0.1') = '^10[.]0[.]0[.]1$'
  AND like_to_rlike('2*3') = '^2[*]3$'
;
