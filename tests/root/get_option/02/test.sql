SET @options = '{x:3, y:4, z:5, unused:8}';

SELECT 
  get_option(@options, 'x') = '3'
  and get_option(@options, 'y') = '4'
  and get_option(@options, 'z') = '5'
;

