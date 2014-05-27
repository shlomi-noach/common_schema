SET @s := '
  set @x := 3;
  set @result := '''';
  while (@x > 0)
  {
    var $a;
    set $a := @x + 1;
    set @result := CONCAT(@result, $a, '','');
    set @x := @x - 1;
  }
';
call run(@s);

select @result = '4,3,2,';

