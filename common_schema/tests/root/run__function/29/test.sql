SET @s := "

function f($a)
{
  set @result := concat(@result, $a);
  return ;
  set @result := 'no way';
}


function primary_function() {
foreach ($i: 1:5) 
  invoke f($i);
}

set @result := '';
invoke primary_function();
";

call run(@s);

select @result = '12345';
