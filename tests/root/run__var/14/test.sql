SET @s := "
  set @res := '';
  foreach ($i: 1:3)
  {
    var $a := $i;
    set @res := concat(@res, $a, ',');
  }
";
call run(@s);

select @res = '1,2,3,';
