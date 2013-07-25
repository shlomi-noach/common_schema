
DROP TABLE IF EXISTS _global_script_report_data;

create table _global_script_report_data(
    id bigint unsigned AUTO_INCREMENT,
    info text charset utf8,
    server_id int unsigned not null,
    session_id int unsigned not null,
    PRIMARY KEY (id, server_id, session_id),
    KEY (server_id, session_id)
) ENGINE=InnoDB ;
