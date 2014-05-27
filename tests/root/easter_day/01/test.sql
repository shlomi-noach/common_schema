SELECT 
  easter_day('2013-12-31') = DATE('2013-03-31')
  AND easter_day('2012-01-01') = DATE('2012-04-08')
  AND easter_day('2011-01-01') = DATE('2011-04-24')
  AND easter_day('2010-08-27') = DATE('2010-04-04')
;

  