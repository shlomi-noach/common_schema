SET @s := '
var $x;
{
  var $x;
}
';
call run(@s);

select 1;
