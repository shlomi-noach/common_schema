SET @options = '{x : 3, y : NULL, z: 5}';

SELECT 
  get_option(@options, 'x') = '3'
  and get_option(@options, 'y') IS NULL
  and get_option(@options, 'z') = '5'
;

