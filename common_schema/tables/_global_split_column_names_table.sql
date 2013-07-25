
DROP TABLE IF EXISTS _global_split_column_names_table;

create table _global_split_column_names_table(
    server_id int unsigned not null,
    session_id int unsigned not null,
    column_order TINYINT UNSIGNED,
    split_table_name varchar(128) charset utf8,
    split_index_name varchar(128) charset utf8,
    column_name VARCHAR(128) charset utf8,
    min_variable_name VARCHAR(128) charset utf8,
    max_variable_name VARCHAR(128) charset utf8,
    range_start_variable_name VARCHAR(128) charset utf8,
    range_end_variable_name VARCHAR(128) charset utf8,
    PRIMARY KEY(server_id, session_id, column_order)
) ENGINE=InnoDB ;
