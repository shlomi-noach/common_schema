
SET @s := "
  set @res := 17;
  var $x := 3;
  if (:$x > 2) {
    set @res := 23;
  }
  else {
    set @res := 29;
  }
";
call run(@s);

select @res = 23;
