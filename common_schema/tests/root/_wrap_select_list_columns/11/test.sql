SET @query := 'SELECT City.id, City . name AS city_name, City . Population FROM world.City';
CALL _wrap_select_list_columns(@query, 0, @error);
SELECT @query;
