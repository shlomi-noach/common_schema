SET @options = '{"x:home":3, `y,o,y`:4, `z and friends`:5, unused:8}';

SELECT 
  get_option(@options, 'x:home') = '3'
  and get_option(@options, 'y,o,y') = '4'
  and get_option(@options, 'z and friends') = '5'
;

