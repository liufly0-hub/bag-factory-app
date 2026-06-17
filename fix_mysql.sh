#!/bin/bash
mysql -u root <<'EOSQL'
ALTER USER root@localhost IDENTIFIED VIA mysql_native_password USING PASSWORD('factory888');
FLUSH PRIVILEGES;
SELECT user,host,plugin FROM mysql.user WHERE user='root';
EOSQL