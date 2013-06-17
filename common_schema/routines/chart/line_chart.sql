--
--

DELIMITER $$

DROP PROCEDURE IF EXISTS line_chart $$
CREATE PROCEDURE line_chart(
	IN values_query TEXT, 
	IN chart_legend TEXT
  )
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'ascii line chart'

begin
  set @_line_chart_values_query := values_query;
  call _wrap_select_list_columns(@_line_chart_values_query, 9, @common_schema_error);
  set @multi_line_chart_num_values := @_wrap_select_num_original_columns - 1;
	
  set @multi_line_chart_bar_length := NULL;
  set @multi_line_chart_values_legend := ifnull(chart_legend, '');
  set @multi_line_chart_min_value := NULL;
  set @multi_line_chart_max_value := NULL;
  set @multi_line_chart_graph_rows := 17;
  set @_line_chart_query := "
	SELECT
	  cast(y_scale as decimal(64,${multi_line_chart_value_precision})) as y_scale,
	  horizontal_bar as chart
	  FROM
	  (
	  SELECT
	    @multi_line_chart_row_number := @multi_line_chart_row_number+1,
	    CASE @multi_line_chart_row_number
	      WHEN 1                            THEN @multi_line_chart_max_value
	      WHEN @multi_line_chart_graph_rows THEN @multi_line_chart_min_value
	      ELSE                              @multi_line_chart_max_value-(@multi_line_chart_max_value-@multi_line_chart_min_value)*(@multi_line_chart_row_number-1)/(@multi_line_chart_graph_rows-1)
	    END AS y_scale,
	    horizontal_bar,
	    @multi_line_chart_bar_length := IFNULL(@multi_line_chart_bar_length, CHAR_LENGTH(horizontal_bar))
	  FROM
	    (SELECT @multi_line_chart_row_number := 0) AS select_row
	    INNER JOIN
	    (
	    SELECT
	      GROUP_CONCAT(SUBSTRING(unwalked_bar, numbers.n, 1) ORDER BY ordering_column SEPARATOR '') AS horizontal_bar
	    FROM
	      numbers
	    INNER JOIN (
	      SELECT
	        ordering_column,
	        GROUP_CONCAT(bar_string_token ORDER BY string_position SEPARATOR '') AS unwalked_bar
	      FROM
	        (SELECT
	          ordering_column,
	          string_position,
	          min(scaled_string_position) as scaled_string_position,
	          REPLACE(LEFT(GROUP_CONCAT(bar_string_token ORDER BY bar_string_token DESC SEPARATOR ''), 1), ' ', '-') AS bar_string_token
	        FROM
	          (SELECT
	            ordering_column,
	            @multi_line_chart_scaled_string_position := CONVERT((row_value-@multi_line_chart_min_value)*(@multi_line_chart_graph_rows-1)/(@multi_line_chart_max_value-@multi_line_chart_min_value), UNSIGNED) AS scaled_string_position,
	            n AS string_position,
	            IF(numbers.n = @multi_line_chart_scaled_string_position+1, SUBSTRING(@multi_line_chart_graph_colors, row_value_indicator, 1), ' ') AS bar_string_token
	          FROM
	            numbers,
	            (SELECT
	              ordering_column,
	              n AS row_value_indicator,
	              row_value
	            FROM (
	              SELECT
	                *,
	                @multi_line_chart_min_value := LEAST(IFNULL(cast(@multi_line_chart_min_value as decimal(64,20)), row_value), IFNULL(row_value, cast(@multi_line_chart_min_value as decimal(64,20)))) AS min_value,
    	            @multi_line_chart_max_value := GREATEST(IFNULL(cast(@multi_line_chart_max_value as decimal(64,20)), row_value), IFNULL(row_value, cast(@multi_line_chart_max_value as decimal(64,20)))) AS max_value,
	                @multi_line_chart_min_range := LEAST(IFNULL(@multi_line_chart_min_range, ordering_column), ordering_column) AS min_range,
	                @multi_line_chart_max_range := GREATEST(IFNULL(@multi_line_chart_max_range, ordering_column), ordering_column) AS max_range
	              FROM
	                (SELECT
	                  *,
	                  col1 as ordering_column,
	                  cast(
                        case n
	                      when 1 then col2   
	                      when 2 then col3   
	                      when 3 then col4   
	                      when 4 then col5   
	                      when 5 then col6   
	                      when 6 then col7   
	                      when 7 then col8   
	                      when 8 then col9   
	                    end 
                        as DECIMAL(64,20)
                      ) AS row_value
	                FROM
	                  numbers,
	                  (${wrapped_query}) AS sel_main_values,
	                  (SELECT @multi_line_chart_bar_length := NULL) AS select_nullify_bar_length,
	                  (SELECT @multi_line_chart_min_range := NULL) AS select_min_range,
	                  (SELECT @multi_line_chart_max_range := NULL) AS select_max_range,
	                  (SELECT @multi_line_chart_graph_colors := '#*@%o+x;m:') AS select_graph_colors,
	                  (SELECT @multi_line_chart_graph_fallback_colors := 'abcdefghij') AS select_graph_fallback_colors,
	                  (SELECT @multi_line_chart_value_precision := 2) AS select_value_precision	                  
	                WHERE
	                  numbers.n BETWEEN 1 AND @multi_line_chart_num_values
	                ) sel_counted_values_main_values
	              ) sel_row_values
	            ) AS sel_row_values_indicators
	          WHERE
	            numbers.n BETWEEN 1 AND @multi_line_chart_graph_rows
	          ) AS sel_marked_row_values
	        GROUP BY
	          ordering_column, string_position
	        ) AS sel_walked_bar
	      GROUP BY
	        ordering_column
	    ) AS select_vertical
	    WHERE
	      numbers.n BETWEEN 1 AND CHAR_LENGTH(unwalked_bar)
	    GROUP BY
	      numbers.n
	    ORDER BY
	      numbers.n DESC
	    ) AS select_horizontal
	  ) AS select_horizontal_untitled
	UNION ALL
	SELECT '', CONCAT('v', REPEAT(':', @multi_line_chart_bar_length-2), 'v')
	UNION ALL
	SELECT '', CONCAT(@multi_line_chart_min_range, REPEAT(' ', @multi_line_chart_bar_length-CHAR_LENGTH(@multi_line_chart_min_range)-CHAR_LENGTH(@multi_line_chart_max_range)), @multi_line_chart_max_range)
	UNION ALL
	SELECT
	  '', CONCAT('    ', SUBSTRING(@multi_line_chart_graph_colors, n, 1), ' ', trim_wspace(SUBSTRING_INDEX(SUBSTRING_INDEX(@multi_line_chart_values_legend, ',', n), ',', -1)))
	FROM
	  numbers
	WHERE
	  n BETWEEN 1 AND @multi_line_chart_num_values
	  AND @multi_line_chart_values_legend IS NOT NULL

  ";
  set @_line_chart_query := replace(@_line_chart_query, '${wrapped_query}', @_line_chart_values_query);
  set @_line_chart_query := replace(@_line_chart_query, '${multi_line_chart_value_precision}', @multi_line_chart_value_precision);
  
  call exec_single(@_line_chart_query);
end $$

DELIMITER ;
