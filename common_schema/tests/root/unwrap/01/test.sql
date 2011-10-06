SELECT 
  unwrap('{set}') = 'set'
  AND unwrap('[list]') = 'list'
  AND unwrap('(precedence)') = 'precedence'
  AND unwrap('{[no nesting]}') = '[no nesting]'
;
