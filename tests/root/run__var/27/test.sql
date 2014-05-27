
SET @s := "
  var $flag := 0;
  var $condition := '$flag' ;

  if (:$condition) {
  }
";
call run(@s);
