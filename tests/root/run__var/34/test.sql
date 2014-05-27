SET @s := '
foreach($x : 1:3)
{
  var $x;
}
';
call run(@s);

select 1;
