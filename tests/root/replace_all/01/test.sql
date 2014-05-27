SELECT 
  replace_all('red, green, blue', ' ,', '-') = 'red--green--blue'
  AND replace_all('gimps wimps limps', ' s;', ',') = 'gimp,,wimp,,limp,'
  AND replace_all('not found', '-', '_') = 'not found'
  AND replace_all('c-o_m*p%r**e!!s-s', '!-_*-%', '') = 'compress'
;
