SET @s := "

function f($a)
{
  set @result := concat(@result, $a);
  break;
  set @result := 'no way';
}

set @result := '';


foreach ($i: 1:5) 
  invoke f($i);

";

call run(@s);

select 1;
