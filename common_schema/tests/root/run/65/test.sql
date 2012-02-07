SET @s := '
  set @result := TRUE;

  var $a;
  if ($a is not null)
  {
    set @result := FALSE; 
  }
';
call run(@s);

select @result IS TRUE;

