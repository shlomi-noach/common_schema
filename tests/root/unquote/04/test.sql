SELECT 
  unquote('') = ''
  AND unquote('"') = '"'
  AND unquote('x') = 'x'
  AND unquote('""') = ''
;
