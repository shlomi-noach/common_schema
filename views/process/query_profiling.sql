-- 
-- Summary view on INFORMATION_SCHEMA.PROFILING
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW _query_profiling_summary AS
  SELECT 
    QUERY_ID,
    COUNT(*) AS count_state_calls,
    COUNT(DISTINCT STATE) AS count_distinct_states,
    SUM(DURATION) AS sum_duration,
    SUM(CPU_USER) AS sum_cpu_user,
    SUM(CPU_SYSTEM) AS sum_cpu_system,
    SUM(SWAPS) AS sum_swpas
  FROM 
    INFORMATION_SCHEMA.PROFILING
  GROUP BY
    QUERY_ID
  ORDER BY
    QUERY_ID
;


-- 
-- Summary view on INFORMATION_SCHEMA.PROFILING
-- 
CREATE OR REPLACE
ALGORITHM = TEMPTABLE
SQL SECURITY INVOKER
VIEW _query_profiling_minmax AS
  SELECT 
    MIN(QUERY_ID) AS min_query_id,
    MAX(QUERY_ID) AS max_query_id
  FROM 
    INFORMATION_SCHEMA.PROFILING
;

-- 
-- Per query profiling info, aggregated by STATE, such that info is displayed per state and
-- relative to general query info
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW query_profiling AS
  SELECT 
    QUERY_ID,
    STATE,
    COUNT(*) AS state_calls,
    SUM(DURATION) AS state_sum_duration,
    SUM(DURATION)/COUNT(*) AS state_duration_per_call,
    ROUND(100.0 * SUM(DURATION) / MAX(_query_profiling_summary.sum_duration), 2) AS state_duration_pct,
    GROUP_CONCAT(SEQ ORDER BY SEQ) AS state_seqs
  FROM 
    INFORMATION_SCHEMA.PROFILING
    JOIN _query_profiling_summary USING(QUERY_ID)
  GROUP BY
    QUERY_ID, STATE
;

-- 
-- Profiling info for last query, aggregated by STATE
-- 
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW last_query_profiling AS
  SELECT 
    query_profiling.*
  FROM 
    query_profiling
    JOIN _query_profiling_minmax ON (query_profiling.QUERY_ID = _query_profiling_minmax.max_query_id)
;
