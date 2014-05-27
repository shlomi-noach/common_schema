SET @options = '{x:3}';

SELECT 
  get_option(@options, 'x') = '3'
;

