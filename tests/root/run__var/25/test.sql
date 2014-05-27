
SET @s := "
  set @res := 17;
  var $x := '';
  if ( :${x} ) {
    set @res := 23;
  }
  else {
    set @res := 29;
  }
";
call run(@s);
