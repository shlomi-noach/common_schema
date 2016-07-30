common_schema
=============

DBA's framework for MySQL

[common_schema Documentation](http://shlomi-noach.github.io/common_schema/introduction.html)


DBA's framework for MySQL

common_schema is a framework for MySQL server administration.

common_schema 2.2 released

common_schema 2.1 released

common_schema 2.0.0-alpha released, and includes rdebug: Debugger and Debugging API for MySQL Stored Routines!

common_schema provides with: * A function library (text functions, security routines, execution and flow control, more...) * A set of informational and analysis views (security, schema design, processes, transactions, more...) * QueryScript interpreter, allowing for server side scripting. * rdebug: a debugger and debugging API for MySQL stored routines (alpha)

It introduces SQL based tools which simplify otherwise complex shell and client scripts, allowing the DBA to be independent of operating system, installed packages and dependencies.

It is a self contained schema, compatible with all MySQL >= 5.1 servers. Installed by importing the schema into the server, there is no need to configure nor compile. No special plugins are required, and no changes to your configuration.

common_schema has a small footprint (under 1MB).

"The common_schema is to MySQL as jQuery is to javaScript" # Baron Schwartz, High Performance MySQL, 3rd Edition

Documentation: a thorough guide to routines, views, the QueryScript language. Also available for download

Bug reports

Announcements on developer's blog

Requirements
common_schema supports MySQL 5.1, 5.5, 5.6. It supports Percona Server & MariaDB.

common_schema enables features, upon installation, according to available server features.

On some versions you may need to set stack_size = 256K in your MySQL configuration file (256K is the default value as of MySQL 5.5)

License
common_schema 2.0 is licensed under the GPL license. Older versions are released under the New BSD License
