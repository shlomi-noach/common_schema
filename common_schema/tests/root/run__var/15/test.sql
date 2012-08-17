SET @s := "
  var $x := 3;
  set @res := :$x;
";
call run(@s);

select @res = 3;
