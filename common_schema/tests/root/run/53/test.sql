SET @s := '
{
  throw ''error on purpose'';
}
';
call run(@s);



