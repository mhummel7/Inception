#!/bin/bash
set -e

# Verzeichnisse anlegen
mkdir -p /var/run/mysqld /var/log/mysql
chown -R mysql:mysql /var/run/mysqld /var/log/mysql /var/lib/mysql
chmod 777 /var/run/mysqld

# Falls Volume leer → init
if [ ! -d /var/lib/mysql/${MYSQL_DATABASE} ]; then
    echo "Initializing MariaDB data directory..."
    mariadb-install-db --datadir=/var/lib/mysql --user=mysql --skip-test-db > /dev/null

    echo "Starting temporary MariaDB with mysqld_safe..."
    mysqld_safe --skip-networking --socket=/var/run/mysqld/mysqld.sock &
    PID=$!
    
    # Warte, bis temporärer Server ready ist (fixte den Hang)
    for i in {1..30}; do
        if mysql --socket=/var/run/mysqld/mysqld.sock -u root -e "SELECT 1" &> /dev/null; then
            break
        fi
        sleep 1
    done

    # Init-SQL mit Socket
    mysql --socket=/var/run/mysqld/mysqld.sock -u root <<EOF
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

FLUSH PRIVILEGES;
EOF

    kill $PID
    wait $PID || true
fi

echo "Starting final MariaDB..."
exec mysqld --user=mysql --bind-address=0.0.0.0 --port=3306