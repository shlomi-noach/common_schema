
DROP TABLE IF EXISTS _global_script_report_data;

create table _global_script_report_data(
    id int unsigned AUTO_INCREMENT,
    info text charset utf8,
    session_id int unsigned not null,
    PRIMARY KEY (id),
    KEY (session_id)
) ENGINE=InnoDB ;
