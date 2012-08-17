
SET @s := "
  set @counter := 23;
  var $condition := '@counter > 17';

  while (:$condition) {
    set @counter := @counter - 1;
  }
";
call run(@s);

select @counter = 17;
