SET @query := 'SELECT DISTINCT id, name AS city_name FROM world.City';
CALL _wrap_select_list_columns(@query, 3, @error);
SET @query := REPLACE(@query, '  ', ' ');
SET @query := REPLACE(@query, '  ', ' ');
SELECT @query;
