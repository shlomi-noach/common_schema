SELECT 
  sql_drop_keys = 'DROP KEY `dt_name_idx`, DROP KEY `id`, DROP KEY `i_dt`, DROP KEY `name_uniq_idx`, DROP PRIMARY KEY'
  AND sql_add_keys = 'ADD KEY `dt_name_idx`(`dt`,`name`(10)), ADD KEY `id`(`id`), ADD UNIQUE KEY `i_dt`(`i`,`dt`), ADD UNIQUE KEY `name_uniq_idx`(`name`), ADD PRIMARY KEY (`id`)'
FROM 
  sql_alter_table 
WHERE 
  table_schema='test_cs' 
  AND table_name='test_sql_alter_table'
;
