SET @s := "

set @result := '';
function f($a)
{
  set @result := concat(@result, $a);
}

foreach ($i: 1:5) 
  invoke f($i);
";
call run(@s);

select @result = '12345';
