SELECT 
  replace_sections('quick [brown fox] jumps over a [dog]', '[', ']', 'green frog') 
    = 'quick green frog jumps over a green frog';