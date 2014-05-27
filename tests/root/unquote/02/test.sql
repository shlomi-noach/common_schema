SELECT 
  unquote('/re') = '/re'
  AND unquote('name\'') = 'name\''
  AND unquote('free text') = 'free text'
;
