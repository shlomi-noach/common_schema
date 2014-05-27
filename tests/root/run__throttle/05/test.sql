SET @s := '
{
  set @x := 1;
  var $throttle_ratio := 1;
  throttle $throttle_ratio;
}
';
call run(@s);

select @x = 1;


