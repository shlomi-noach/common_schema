SET @s := "
set @result := 17;

function f()
{
  set @result := 23;
}

";
call run(@s);

select @result = 17;
