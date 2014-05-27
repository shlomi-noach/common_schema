SET @s := '
    set @x := 3
';

call run(@s);

select @x = 3;

