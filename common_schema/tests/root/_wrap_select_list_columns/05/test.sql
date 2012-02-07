SET @query := 'SELECT id, name AS city_name, (select IF(population < 1000000, \'small\', \'large\') AS size_description), _latin1 ''boe'' FROM world.City';
CALL _wrap_select_list_columns(@query, 5, @error);
SET @query := REPLACE(@query, '  ', ' ');
SET @query := REPLACE(@query, '  ', ' ');
SELECT @query;
