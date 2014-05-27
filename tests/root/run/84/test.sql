SET @s := '
  var $x;
  set $x := 3;
  set @y := :$x;
';
call run(@s);

select @y = 3;

