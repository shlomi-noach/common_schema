SET @query := 'SELECT id, name AS city_name, IF(population < 1000000, \'small\', \'large\') AS size_description FROM world.City';
CALL _wrap_select_list_columns(@query, 6, @error);
SELECT @_wrap_select_num_original_columns = 3;
