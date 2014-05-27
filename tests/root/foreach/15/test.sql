set @result := '';

CALL foreach('1:3', '
  input $x;
  if (6 > 5)
  {
    set @result := CONCAT(@result, $x);
  }
');

SELECT @result = '123';

