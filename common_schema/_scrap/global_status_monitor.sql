-- 
-- (Internal use): double sample of GLOBAL_STATUS with time delay
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW _global_status_double_sample AS
  (
    SELECT 
      1 AS group_order,
      VARIABLE_NAME,
      VARIABLE_VALUE,
      0-VARIABLE_VALUE AS VARIABLE_VALUE_ELEMENT
    FROM
      INFORMATION_SCHEMA.GLOBAL_STATUS
  )
  UNION ALL
  (
    SELECT 
      1 AS group_order, 
      '_meta_unix_timestamp', 
      UNIX_TIMESTAMP(SYSDATE()), 
      0-UNIX_TIMESTAMP(SYSDATE())
  )
  UNION ALL
  (
    SELECT 
      0 AS group_order, 
      '', 
      SLEEP(10), 
      0
  )
  UNION ALL
  (
    SELECT 
      2 AS group_order,
      VARIABLE_NAME,
      VARIABLE_VALUE,
      VARIABLE_VALUE AS VARIABLE_VALUE_ELEMENT
    FROM
      INFORMATION_SCHEMA.GLOBAL_STATUS
  )
  UNION ALL
  (
    SELECT 
      2 AS group_order, 
      '_meta_unix_timestamp', 
      UNIX_TIMESTAMP(SYSDATE()), 
      UNIX_TIMESTAMP(SYSDATE())
  )
;

-- 
-- Status variables difference over time, with interpolation and extrapolation per time unit  
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW global_status_monitor AS
  SELECT 
    LOWER(VARIABLE_NAME) AS variable_name,
    CAST(SUBSTRING_INDEX(GROUP_CONCAT(VARIABLE_VALUE ORDER BY group_order ASC), ',' ,1) AS SIGNED) AS variable_value_0,
    CAST(SUBSTRING_INDEX(GROUP_CONCAT(VARIABLE_VALUE ORDER BY group_order DESC), ',' ,1) AS SIGNED) AS variable_value_1,
    SUM(VARIABLE_VALUE_ELEMENT) AS variable_value_diff,
    SUM(VARIABLE_VALUE_ELEMENT)/10 AS variable_value_psec,
    SUM(VARIABLE_VALUE_ELEMENT)*60/10 AS variable_value_pminute
  FROM
    _global_status_double_sample
  WHERE
    VARIABLE_NAME != ''
  GROUP BY 
    VARIABLE_NAME
;
