SET @s := "
  var $x := 'IF(3 > 2, 23, 19)';
  SELECT :${x} INTO @res;
";
call run(@s);

select @res = 23;
