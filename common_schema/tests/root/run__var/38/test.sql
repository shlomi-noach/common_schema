SET @s := '
select n from numbers where n between 13 and 17;

select $found_rows;
';

call run(@s);
