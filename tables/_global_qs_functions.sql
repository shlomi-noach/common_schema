
DROP TABLE IF EXISTS _global_qs_functions;

create table _global_qs_functions(
    server_id int unsigned not null,
    session_id int unsigned not null,
    function_name VARCHAR(65) CHARSET ascii NOT NULL,
    declaration_id INT UNSIGNED NOT NULL,
    arguments_declaration_id INT UNSIGNED NOT NULL,
    scope_start_id INT UNSIGNED NOT NULL,
    scope_end_id INT UNSIGNED NOT NULL,
    count_function_arguments INT UNSIGNED NOT NULL,
    function_arguments TEXT DEFAULT NULL,
    PRIMARY KEY(server_id, session_id, function_name),
    KEY(declaration_id)
) ENGINE=InnoDB ;
