CREATE OR REPLACE VIEW test_cs.existing_view AS SELECT 1;
SELECT 
  table_exists('test_cs', 'existing_view')
;

