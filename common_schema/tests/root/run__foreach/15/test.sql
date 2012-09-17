SET @s := '
  set @other := 17;
  foreach($a : {})
  {
    set @other := 2;
  }
  otherwise 
  {
    set @other := 41;
  }
';
call run(@s);
SELECT @other = 41;

