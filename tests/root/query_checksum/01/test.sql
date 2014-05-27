call query_checksum('select distinct n from (select cast(n/10 as unsigned) as n from numbers) s1 order by n');
call query_checksum('select n from (select cast(n/10 as unsigned) as n from numbers) s1 group by n order by n');
call query_checksum('select n from numbers where n <= 410');
