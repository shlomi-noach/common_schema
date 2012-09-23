USE test_cs;
drop table if exists tmp_test_sql_range_partitions_weekly;
CREATE TABLE 
  tmp_test_sql_range_partitions_weekly
  LIKE test_sql_range_partitions_weekly ;
