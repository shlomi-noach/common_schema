SET @options = '{first param: 1, second param: the value is 2 }';

SELECT 
  get_option(@options, 'first param') = '1'
  and get_option(@options, 'second param') = 'the value is 2'
;

