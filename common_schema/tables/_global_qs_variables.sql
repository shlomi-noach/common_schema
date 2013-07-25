
DROP TABLE IF EXISTS _global_qs_variables;

create table _global_qs_variables(
    server_id int unsigned not null,
    session_id int unsigned not null,
    variable_name VARCHAR(65) CHARSET ascii NOT NULL,
    mapped_user_defined_variable_name  VARCHAR(65) CHARSET ascii NOT NULL,
    declaration_depth INT UNSIGNED NOT NULL,
    declaration_id INT UNSIGNED NOT NULL,
    scope_end_id INT UNSIGNED NOT NULL,
    value_snapshot TEXT DEFAULT NULL,
    PRIMARY KEY(server_id, session_id, variable_name),
    KEY(declaration_depth),
    KEY(declaration_id),
    KEY(scope_end_id)
) ENGINE=InnoDB ;
