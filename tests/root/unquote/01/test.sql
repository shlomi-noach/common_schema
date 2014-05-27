SELECT 
  unquote('/re/') = 're'
  AND unquote('\'name\'') = 'name'
  AND unquote('\"saying\"') = 'saying'
  AND unquote('\"/no nesting/\"') = '/no nesting/'
;
