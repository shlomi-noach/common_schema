SET @s := '
  var $a := 3;
  set @res := $a;
';
call run(@s);

select @res = 3;
