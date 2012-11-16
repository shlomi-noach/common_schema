SELECT 
  unquote('/re"/') = 're"'
  AND unquote('"sayin"g"') = '"sayin"g"'
  AND unquote('`a`.`b`') = '`a`.`b`'
  AND unquote('`a.b`') = 'a.b'
  AND unquote('`a."b`') = 'a."b'
  AND unquote('`a`.b`') = '`a`.b`'
  AND unquote('`a`.`b') = '`a`.`b'
;
