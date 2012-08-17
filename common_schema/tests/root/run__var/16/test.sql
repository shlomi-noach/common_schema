SET @s := "
  set @ref := 17;
  var $x := '@ref';
  set @res := :$x;
";
call run(@s);

select @res = 17;
