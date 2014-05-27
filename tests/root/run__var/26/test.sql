
SET @s := "
  var $flag := 0;
  var $condition := '$flag' ;

  select :$condition;
";
call run(@s);
