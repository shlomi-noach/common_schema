SET @s := '
  var $a := 3 + (2 * 2);
  set @res := $a;
';
call run(@s);

select @res = 7;
