set @result := '';

CALL foreach('1:3', '
  if (6 > 5)
  {
    set @result := CONCAT(@result, ''z'');
  }
');

SELECT @result = 'zzz';

