SET @s := '
  start transaction;
  rollback;
';
call run(@s);

select 1;
