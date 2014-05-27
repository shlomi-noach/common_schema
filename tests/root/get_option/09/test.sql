SET @options = '{x : 3, y : 5 : 6}';

SELECT 
  get_option(@options, 'y') IS NULL
;

