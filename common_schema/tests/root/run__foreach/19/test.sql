SET @s := '
  set @res := '''';
  var $range := ''{red,green,blue}'';
  foreach($a : :${range})
  {
    set @res := CONCAT(@res, ''-'', $a);
  }
';
call run(@s);
SELECT @res = '-red-green-blue';


