-- 
-- (Internal use): sample of GLOBAL_STATUS with time delay
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW _global_status_sleep AS
  (
    SELECT 
      VARIABLE_NAME,
      VARIABLE_VALUE 
    FROM 
      INFORMATION_SCHEMA.GLOBAL_STATUS
  )
  UNION ALL
  (
    SELECT 
      '' AS VARIABLE_NAME, 
      SLEEP(10) 
    FROM DUAL
  )
;


-- 
-- Status variables difference over time, with interpolation and extrapolation per time unit  
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW global_status_diff AS
  SELECT 
    LOWER(gs0.VARIABLE_NAME) AS variable_name,
    gs0.VARIABLE_VALUE AS variable_value_0,
    gs1.VARIABLE_VALUE AS variable_value_1,
    (gs1.VARIABLE_VALUE - gs0.VARIABLE_VALUE) AS variable_value_diff,
    (gs1.VARIABLE_VALUE - gs0.VARIABLE_VALUE) / 10 AS variable_value_psec,
    (gs1.VARIABLE_VALUE - gs0.VARIABLE_VALUE) * 60 / 10 AS variable_value_pminute
  FROM
    _global_status_sleep AS gs0
    JOIN INFORMATION_SCHEMA.GLOBAL_STATUS gs1 USING (VARIABLE_NAME)
;

-- 
-- Status variables difference over time, with spaces where zero diff encountered  
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW global_status_diff_clean AS
  SELECT 
    variable_name,
    variable_value_0,
    variable_value_1,
    IF(variable_value_diff = 0, '', variable_value_diff) AS variable_value_diff,
    IF(variable_value_diff = 0, '', variable_value_psec) AS variable_value_psec,
    IF(variable_value_diff = 0, '', variable_value_pminute) AS variable_value_pminute
  FROM
    global_status_diff
;

-- 
-- Status variables difference over time, only nonzero findings listed
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW global_status_diff_nonzero AS
  SELECT 
    *
  FROM
    global_status_diff
  WHERE
    variable_value_diff != 0
;
