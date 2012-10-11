SET @s := '
  start transaction;
  commit;
';
call run(@s);

select 1;
