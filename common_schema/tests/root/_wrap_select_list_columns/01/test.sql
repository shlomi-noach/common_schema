SET @query := 'SELECT id, name AS city_name, IF(population < 1000000, \'small\', \'large\') AS size_description FROM world.City';
CALL _wrap_select_list_columns(@query, 3, @error);
SET @query := REPLACE(@query, '  ', ' ');
SET @query := REPLACE(@query, '  ', ' ');
SELECT @query;
