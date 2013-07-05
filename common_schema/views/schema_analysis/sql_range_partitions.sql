-- 
-- 
-- 

CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW _sql_range_partitions_summary AS
  select 
    table_schema, 
    table_name, 
    COUNT(*) as count_partitions,
    SUM(_as_datetime(unquote(PARTITION_DESCRIPTION)) < NOW()) AS count_past_timestamp,
    SUM(_as_datetime(unquote(PARTITION_DESCRIPTION)) >= NOW()) AS count_future_timestamp,
    SUM(IF(PARTITION_DESCRIPTION = 'MAXVALUE', 0, _as_datetime(FROM_UNIXTIME(PARTITION_DESCRIPTION)) < NOW())) AS count_past_from_unixtime,
    SUM(IF(PARTITION_DESCRIPTION = 'MAXVALUE', 0, _as_datetime(FROM_UNIXTIME(PARTITION_DESCRIPTION)) >= NOW())) AS count_future_from_unixtime,
    SUM(IF(PARTITION_DESCRIPTION = 'MAXVALUE', 0, _as_datetime(FROM_DAYS(PARTITION_DESCRIPTION)) < NOW())) AS count_past_from_days,
    SUM(IF(PARTITION_DESCRIPTION = 'MAXVALUE', 0, _as_datetime(FROM_DAYS(PARTITION_DESCRIPTION)) >= NOW())) AS count_future_from_days,
    substring_index(group_concat(PARTITION_NAME order by PARTITION_ORDINAL_POSITION), ',', 1) as first_partition_name,
    substring_index(group_concat(IF((PARTITION_ORDINAL_POSITION = 1 and PARTITION_DESCRIPTION = 0), NULL, PARTITION_NAME) order by PARTITION_ORDINAL_POSITION), ',', 1) as first_partition_name_skipping_zero,    
    substring_index(group_concat(PARTITION_NAME order by PARTITION_ORDINAL_POSITION), ',', -1) as last_partition_name,
    SUM(PARTITION_DESCRIPTION = 'MAXVALUE') as has_maxvalue,
    MAX(IF(PARTITION_DESCRIPTION = 'MAXVALUE', PARTITION_NAME, NULL)) as maxvalue_partition_name,
    MAX(IF(PARTITION_DESCRIPTION != 'MAXVALUE', 
      IFNULL(_as_datetime(unquote(PARTITION_DESCRIPTION)), CAST(PARTITION_DESCRIPTION AS SIGNED)), 
      NULL)
      ) as max_partition_description
  from 
    information_schema.partitions
  where 
    PARTITION_METHOD IN ('RANGE', 'RANGE COLUMNS')
  group by
    table_schema, table_name
;

-- 
-- Diff all values.
-- Ignore first partition if it's "LESS THAN 0" as this is a common use case and is not part of a constant interval.
-- 

CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW _sql_range_partitions_base AS
  select 
    p0.TABLE_SCHEMA, 
    p0.table_name, 
    unquote(p0.PARTITION_DESCRIPTION) as unquoted_description,
    p0.PARTITION_DESCRIPTION >= TO_DAYS('1000-01-01') as valid_from_days,
    p1.PARTITION_DESCRIPTION - p0.PARTITION_DESCRIPTION as diff,
    TIMESTAMPDIFF(DAY, _as_datetime(unquote(p0.PARTITION_DESCRIPTION)), _as_datetime(unquote(p1.PARTITION_DESCRIPTION))) AS diff_day,
    TIMESTAMPDIFF(WEEK, _as_datetime(unquote(p0.PARTITION_DESCRIPTION)), _as_datetime(unquote(p1.PARTITION_DESCRIPTION))) AS diff_week,
    TIMESTAMPDIFF(MONTH, _as_datetime(unquote(p0.PARTITION_DESCRIPTION)), _as_datetime(unquote(p1.PARTITION_DESCRIPTION))) AS diff_month,
    TIMESTAMPDIFF(YEAR, _as_datetime(unquote(p0.PARTITION_DESCRIPTION)), _as_datetime(unquote(p1.PARTITION_DESCRIPTION))) AS diff_year,
    TIMESTAMPDIFF(DAY, _as_datetime(FROM_UNIXTIME(p0.PARTITION_DESCRIPTION)), _as_datetime(FROM_UNIXTIME(p1.PARTITION_DESCRIPTION))) AS diff_day_from_unixtime,
    TIMESTAMPDIFF(WEEK, _as_datetime(FROM_UNIXTIME(p0.PARTITION_DESCRIPTION)), _as_datetime(FROM_UNIXTIME(p1.PARTITION_DESCRIPTION))) AS diff_week_from_unixtime,
    TIMESTAMPDIFF(MONTH, _as_datetime(FROM_UNIXTIME(p0.PARTITION_DESCRIPTION)), _as_datetime(FROM_UNIXTIME(p1.PARTITION_DESCRIPTION))) AS diff_month_from_unixtime,
    TIMESTAMPDIFF(YEAR, _as_datetime(FROM_UNIXTIME(p0.PARTITION_DESCRIPTION)), _as_datetime(FROM_UNIXTIME(p1.PARTITION_DESCRIPTION))) AS diff_year_from_unixtime,
    TIMESTAMPDIFF(DAY, _as_datetime(FROM_DAYS(p0.PARTITION_DESCRIPTION)), _as_datetime(FROM_DAYS(p1.PARTITION_DESCRIPTION))) AS diff_day_from_days,
    TIMESTAMPDIFF(WEEK, _as_datetime(FROM_DAYS(p0.PARTITION_DESCRIPTION)), _as_datetime(FROM_DAYS(p1.PARTITION_DESCRIPTION))) AS diff_week_from_days,
    TIMESTAMPDIFF(MONTH, _as_datetime(FROM_DAYS(p0.PARTITION_DESCRIPTION)), _as_datetime(FROM_DAYS(p1.PARTITION_DESCRIPTION))) AS diff_month_from_days,
    TIMESTAMPDIFF(YEAR, _as_datetime(FROM_DAYS(p0.PARTITION_DESCRIPTION)), _as_datetime(FROM_DAYS(p1.PARTITION_DESCRIPTION))) AS diff_year_from_days
  from 
    information_schema.partitions p0 
    join information_schema.partitions p1 on (p0.table_schema=p1.table_schema and p0.table_name=p1.table_name and p0.PARTITION_ORDINAL_POSITION = p1.PARTITION_ORDINAL_POSITION-1)
  where 
    p0.PARTITION_METHOD IN ('RANGE', 'RANGE COLUMNS')
    and p1.PARTITION_DESCRIPTION != 'MAXVALUE'
    and not (p0.PARTITION_ORDINAL_POSITION = 1 and p0.PARTITION_DESCRIPTION = 0)
;

-- 
-- 
-- 

CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW _sql_range_partitions_diff AS
  select
    table_schema,
    table_name,
    if(count(distinct(diff)) = 1, min(diff), 0) as diff, 
    if(count(distinct(diff_day)) = 1, min(diff_day), 0) as diff_day, 
    if(count(distinct(diff_week)) = 1, min(diff_week), 0) as diff_week, 
    if(count(distinct(diff_month)) = 1, min(diff_month), 0) as diff_month, 
    if(count(distinct(diff_year)) = 1, min(diff_year), 0) as diff_year, 
    if(count(distinct(diff_day_from_unixtime)) = 1, min(diff_day_from_unixtime), 0) as diff_day_from_unixtime, 
    if(count(distinct(diff_week_from_unixtime)) = 1, min(diff_week_from_unixtime), 0) as diff_week_from_unixtime, 
    if(count(distinct(diff_month_from_unixtime)) = 1, min(diff_month_from_unixtime), 0) as diff_month_from_unixtime, 
    if(count(distinct(diff_year_from_unixtime)) = 1, min(diff_year_from_unixtime), 0) as diff_year_from_unixtime, 
    if((count(distinct(diff_day_from_days)) = 1) and min(valid_from_days), min(diff_day_from_days), 0) as diff_day_from_days, 
    if((count(distinct(diff_week_from_days)) = 1) and min(valid_from_days), min(diff_week_from_days), 0) as diff_week_from_days, 
    if((count(distinct(diff_month_from_days)) = 1) and min(valid_from_days), min(diff_month_from_days), 0) as diff_month_from_days, 
    if((count(distinct(diff_year_from_days)) = 1) and min(valid_from_days), min(diff_year_from_days), 0) as diff_year_from_days
  from
    _sql_range_partitions_base
  group by
    table_schema, table_name
;


-- 
-- 
-- 

CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW _sql_range_partitions_analysis AS
  select
    _sql_range_partitions_summary.*,
    substring_index(case
      when diff_year_from_unixtime != 0 then unix_timestamp(from_unixtime(max_partition_description) + interval diff_year_from_unixtime year)
      when diff_month_from_unixtime != 0 then unix_timestamp(from_unixtime(max_partition_description) + interval diff_month_from_unixtime month)
      when diff_week_from_unixtime != 0 then unix_timestamp(from_unixtime(max_partition_description) + interval diff_week_from_unixtime week)
      when diff_day_from_unixtime != 0 then unix_timestamp(from_unixtime(max_partition_description) + interval diff_day_from_unixtime day)
      when diff_year_from_days != 0 then to_days(from_days(max_partition_description) + interval diff_year_from_days year)
      when diff_month_from_days != 0 then to_days(from_days(max_partition_description) + interval diff_month_from_days month)
      when diff_week_from_days != 0 then to_days(from_days(max_partition_description) + interval diff_week_from_days week)
      when diff_day_from_days != 0 then to_days(from_days(max_partition_description) + interval diff_day_from_days day)
      when diff_year != 0 then max_partition_description + interval diff_year year
      when diff_month != 0 then max_partition_description + interval diff_month month
      when diff_week != 0 then max_partition_description + interval diff_week week
      when diff_day != 0 then max_partition_description + interval diff_day day
      when diff != 0 then max_partition_description + diff
      else NULL
    end, '.', 1) as next_partition_description,
    substring_index(case
      when diff_year_from_unixtime != 0 then (from_unixtime(max_partition_description) + interval diff_year_from_unixtime year)
      when diff_month_from_unixtime != 0 then (from_unixtime(max_partition_description) + interval diff_month_from_unixtime month)
      when diff_week_from_unixtime != 0 then (from_unixtime(max_partition_description) + interval diff_week_from_unixtime week)
      when diff_day_from_unixtime != 0 then (from_unixtime(max_partition_description) + interval diff_day_from_unixtime day)
      when diff_year_from_days != 0 then (from_days(max_partition_description) + interval diff_year_from_days year)
      when diff_month_from_days != 0 then (from_days(max_partition_description) + interval diff_month_from_days month)
      when diff_week_from_days != 0 then (from_days(max_partition_description) + interval diff_week_from_days week)
      when diff_day_from_days != 0 then (from_days(max_partition_description) + interval diff_day_from_days day)
      when diff_year != 0 then max_partition_description + interval diff_year year
      when diff_month != 0 then max_partition_description + interval diff_month month
      when diff_week != 0 then max_partition_description + interval diff_week week
      when diff_day != 0 then max_partition_description + interval diff_day day
      when diff != 0 then max_partition_description + diff
      else NULL
    end, '.', 1) as next_partition_human_description,
    case
      when (diff_year_from_unixtime != 0 or diff_month_from_unixtime != 0 or diff_week_from_unixtime or diff_day_from_unixtime != 0) then count_past_from_unixtime
      when (diff_year_from_days != 0 or diff_month_from_days != 0 or diff_week_from_days != 0 or diff_day_from_days != 0) then count_past_from_days
      when (diff_year != 0 or diff_month != 0 or diff_week != 0 or diff_day != 0) then count_past_timestamp
      else NULL
    end as count_past_partitions,
    case
      when (diff_year_from_unixtime != 0 or diff_month_from_unixtime != 0 or diff_week_from_unixtime or diff_day_from_unixtime != 0) then count_future_from_unixtime
      when (diff_year_from_days != 0 or diff_month_from_days != 0 or diff_week_from_days != 0 or diff_day_from_days != 0) then count_future_from_days
      when (diff_year != 0 or diff_month != 0 or diff_week != 0 or diff_day != 0) then count_future_timestamp
      else NULL
    end as count_future_partitions
  from
    _sql_range_partitions_diff
    join _sql_range_partitions_summary using (table_schema, table_name)
;


-- 
-- 
-- 

CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW _sql_range_partitions_beautified AS
  select
    *,
    CONCAT('p_', IFNULL(DATE_FORMAT(_as_datetime(next_partition_human_description), '%Y%m%d%H%i%s'), next_partition_human_description)) as next_partition_name,
    (_as_datetime(next_partition_human_description) is not null) as next_partition_human_description_is_datetime,
    IFNULL(CONCAT(' /* ', _as_datetime(next_partition_human_description), ' */ '), '') as next_partition_human_description_comment
  from
    _sql_range_partitions_analysis
;

-- 
-- Generate SQL statements for managing range partitions
-- Generates DROP/ADD/REORGANIZE statements which drops oldest
-- partition, as well as creating/adding next partition, reorganizing if required.
-- 

CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW sql_range_partitions AS
  select
    table_schema,
    table_name,
    count_partitions,
    count_past_partitions,
    count_future_partitions,
    has_maxvalue,
    CONCAT('alter table ', mysql_qualify(table_schema), '.', mysql_qualify(table_name), ' drop partition ', mysql_qualify(first_partition_name_skipping_zero)) as sql_drop_first_partition,
    IF (has_maxvalue,
      CONCAT(
        'alter table ', mysql_qualify(table_schema), '.', mysql_qualify(table_name), 
        ' reorganize partition ', mysql_qualify(last_partition_name), 
        ' into (partition ', mysql_qualify(next_partition_name), ' values less than (', IF(is_datetime(next_partition_description), quote(next_partition_description), next_partition_description), 
        ')', next_partition_human_description_comment, ', partition p_maxvalue values less than MAXVALUE', ')'),
      CONCAT('alter table ', mysql_qualify(table_schema), '.', mysql_qualify(table_name), 
        ' add partition (partition ', mysql_qualify(next_partition_name), ' values less than (', IF(is_datetime(next_partition_description), quote(next_partition_description), next_partition_description), ')', next_partition_human_description_comment, ')')
      ) as sql_add_next_partition
  from
    _sql_range_partitions_beautified
;
