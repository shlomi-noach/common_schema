USE test_cs;

drop table if exists test_sql_alter_table;
CREATE TABLE test_sql_alter_table (
    id INT AUTO_INCREMENT,
    name varchar(64) NOT NULL,
    dt DATETIME NOT NULL,
    i INT,
    
    PRIMARY KEY(id),
    KEY `id` (id),
    UNIQUE KEY `name_uniq_idx` (name),
    KEY `dt_name_idx` (dt, name(10)),
    UNIQUE KEY `i_dt` (i, dt)    
) ENGINE=MYISAM ROW_FORMAT=DYNAMIC
;
