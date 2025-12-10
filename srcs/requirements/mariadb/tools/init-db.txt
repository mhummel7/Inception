#!/bin/bash
set -e

# Secrets auslesen
if [ -f /run/secrets/mysql_root_password ]; then
    MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mysql_root_password)
fi
if [ -f /run/secrets/mysql_password ]; then
    MYSQL_PASSWORD=$(cat /run/secrets/mysql_password)
fi

# Sicherheit: Abbruch, falls nicht gesetzt
[ -z "$MYSQL_ROOT_PASSWORD" ] && { echo "MYSQL_ROOT_PASSWORD missing"; exit 1; }
[ -z "$MYSQL_PASSWORD" ] && { echo "MYSQL_PASSWORD missing"; exit 1; }

# Verzeichnisse
mkdir -p /var/run/mysqld /var/log/mysql
chown -R mysql:mysql /var/run/mysqld /var/log/mysql /var/lib/mysql
chmod 777 /var/run/mysqld

# Nur bei leerem Volume initialisieren
if [ ! -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then
    echo "Initializing MariaDB..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db >/dev/null

    mysqld --user=mysql --skip-networking --socket=/var/run/mysqld/mysqld.sock &
    PID=$!

    for i in {30..1}; do
        if mysql --socket=/var/run/mysqld/mysqld.sock -uroot -e "SELECT 1" &>/dev/null; then
            break
        fi
        sleep 1
    done

    mysql --socket=/var/run/mysqld/mysqld.sock -uroot <<EOF
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost','127.0.0.1','::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    kill $PID
    wait $PID 2>/dev/null || true
fi

echo "Starting MariaDB..."
exec mysqld --user=mysql --bind-address=0.0.0.0 --port=3306