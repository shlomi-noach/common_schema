SET @s := "
set @result := 17;

function f()
{
  set @result := 23;
}
invoke f();

";
call run(@s);

select @result = 23;
