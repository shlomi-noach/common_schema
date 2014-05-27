SET @s := '
set @res := 0;
foreach($i : 1:12)
{
  set @res := @res + 1;
}
foreach($i : 31:35)
{
  set @res := @res + 1;
}
';
call run(@s);

select @res = 17;
