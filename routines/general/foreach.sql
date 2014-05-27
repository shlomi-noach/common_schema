--
-- Invoke queries on each element of given collection.
--
-- This procedure will iterate a given collection. The collection is one of several
-- supported types as described below. For each element in the collection, the routine
-- invokes the given set (one or more) of queries.
--
-- Queries may relate to the particular element at hand, by using placeholders, in similar approach
-- to that used by regular expressions or the awk program.
-- 
-- foreach() supports the following collection types:
-- - Query: the collection is the rowset. An element is a single row.
-- - Numbers range: e.g. '1970:2038'
-- - Two dimentional numbers range: e.g. '-20:20,1970:2038'
-- - Constants set: e.g. '{red, green, blue}'
-- - 'schema': iterate all schemata
-- - 'schema like ...': iterate schemata whose name is like the given text
-- - 'schema ~ ...': iterate schemata whose name matches the given text
-- - 'table like ...': iterate tables whose name is like the given text
-- - 'table ~ ...': iterate tables whose name matches the given text
-- - 'table in schema_name': iterate tables in a given schema
-- 
-- Placeholders vary according to collection type:
-- - Query: ${1} - ${9}
-- - Numbers range: ${1}
-- - Two dimentional numbers range: ${1}, ${2}
-- - Constants set: ${1}
-- - 'schema': ${1} == ${schema}
-- - 'schema like ...': ${1} == ${schema}
-- - 'schema ~ ...': ${1} == ${schema}
-- - 'table like ...': ${1} == ${table}, ${2} == ${schema}
-- - 'table ~ ...': ${1} == ${table}, ${2} == ${schema}
-- - 'table in schema_name': ${1} == ${table}, ${2} == ${schema}
-- All types support the ${NR} placeholder (row number, similar to awk)
-- 

DELIMITER $$

DROP PROCEDURE IF EXISTS foreach $$
CREATE PROCEDURE foreach(collection TEXT CHARSET utf8, execute_queries TEXT CHARSET utf8) 
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Invoke queries per element of given collection'

main_body: begin  
  if collection IS NULL then
    leave main_body;
  end if;
  if execute_queries IS NULL then
    leave main_body;
  end if;
  
  call _foreach(collection, execute_queries, NULL, NULL, NULL, @_common_schema_dummy, NULL, NULL, NULL, @_common_schema_dummy);
end $$

DELIMITER ;
