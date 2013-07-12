--
-- Generate a Google Image multi-line chart URL by an arbitrary query 
--

DELIMITER $$

DROP PROCEDURE IF EXISTS google_line_chart $$
CREATE PROCEDURE google_line_chart(
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
	
  set @multi_line_chart_values_legend := ifnull(chart_legend, '');
  set @multi_line_chart_values_legend := replace(@multi_line_chart_values_legend, ',', '|');
  set @multi_line_chart_values_legend := replace(@multi_line_chart_values_legend, '| ', '|');
  set @multi_line_chart_values_legend := replace(@multi_line_chart_values_legend, ' |', '|');
  set @multi_line_chart_min_value := NULL;
  set @multi_line_chart_max_value := NULL;
  set @multi_line_chart_count_values := 0;
  set @multi_line_chart_colors := SUBSTRING_INDEX('ff8c00,4682b4,9acd32,dc143c,9932cc,ffd700,191970,7fffd4,808080,dda0dd', ',', @multi_line_chart_num_values);
  set @_line_chart_query := "
	SELECT
	  CONCAT(
	    'http://chart.apis.google.com/chart?cht=lc&chs=800x350&chtt=SQL+chart+by+common_schema&chxt=x,y&chxr=1,',
	    ROUND(MIN(min_value), 1), ',',
	    ROUND(MAX(max_value), 1),
	    '&chd=s:',
	    TRIM(LEADING ',' FROM GROUP_CONCAT(
		  IF(count_values = 1, ',', ''),
          IF(
	        row_value IS NULL,
	        '_',
	        SUBSTRING(
	          'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789',
	          1+round(61*(row_value - min_value)/(max_value - min_value)),
	          1
            )
	      )
          ORDER BY n,count_values
	      SEPARATOR ''
	    )),
	   '&chxs=0,505050,10,0,lt',
	   '&chxl=0:|',
	    GROUP_CONCAT(
	      IF(
	        n = 1,
	        IF(
              count_values IN (1, ROUND(@multi_line_chart_count_values/4), ROUND(@multi_line_chart_count_values/2), ROUND (@multi_line_chart_count_values*3/4), @multi_line_chart_count_values),
	          ordering_column,
	          ''
	        ),
	        NULL
	      )
          ORDER BY ordering_column
	      SEPARATOR '|'
	    ),
	   '&chg=', (100.0/(@multi_line_chart_count_values-1)), ',25,1,2,0,0',
       '&chco=${multi_line_chart_colors}',
	   '&chdl=${multi_line_chart_values_legend}',
       '&chdlp=b'
	  ) as google_chart_url
      FROM 
        (
        SELECT 
            n,
            ordering_column,
            row_value,
            count_values,
            @multi_line_chart_min_value AS min_value,
            @multi_line_chart_max_value AS max_value
        FROM
          (SELECT
            *,
            @multi_line_chart_min_value := LEAST(IFNULL(cast(@multi_line_chart_min_value as decimal(64,20)), row_value), IFNULL(row_value, cast(@multi_line_chart_min_value as decimal(64,20)))) AS min_value,
            @multi_line_chart_max_value := GREATEST(IFNULL(cast(@multi_line_chart_max_value as decimal(64,20)), row_value), IFNULL(row_value, cast(@multi_line_chart_max_value as decimal(64,20)))) AS max_value,
            if (n = 1, @multi_line_chart_count_values := @multi_line_chart_count_values + 1, @multi_line_chart_count_values) as count_values
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
              (${wrapped_query}) AS sel_main_values
            WHERE
              numbers.n BETWEEN 1 AND @multi_line_chart_num_values
            ) sel_counted_values_main_values
          ) selec_data
		) select_data_min_max
  ";
  set @_line_chart_query := replace(@_line_chart_query, '${wrapped_query}', @_line_chart_values_query);
  set @_line_chart_query := replace(@_line_chart_query, '${multi_line_chart_colors}', @multi_line_chart_colors);
  set @_line_chart_query := replace(@_line_chart_query, '${multi_line_chart_values_legend}', @multi_line_chart_values_legend);
  
  call exec_single(@_line_chart_query);
end $$

DELIMITER ;
