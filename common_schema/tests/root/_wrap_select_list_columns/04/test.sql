SET @query := 'SELECT id alias1, name AS alias2, name like ''boe'' alias3, name like `boe` alias4, name between district and countrycode alias5, case countrycode when ''NLD'' then 1 else 0 end alias6, id mod 2 alias7, group_concat(name order by name), (select 1 as cons) FROM world.City';
CALL _wrap_select_list_columns(@query, 10, @error);
SET @query := REPLACE(@query, '  ', ' ');
SET @query := REPLACE(@query, '  ', ' ');
SELECT @query;
