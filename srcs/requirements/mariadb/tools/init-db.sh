#!/bin/bash
set -e # Exit on error

# Load secrets
if [ -f /run/secrets/mysql_root_password ]; then
    MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mysql_root_password)
fi
if [ -f /run/secrets/mysql_password ]; then
    MYSQL_PASSWORD=$(cat /run/secrets/mysql_password)
fi

# Safety: exit if not set
[ -z "$MYSQL_ROOT_PASSWORD" ] && { echo "MYSQL_ROOT_PASSWORD missing"; exit 1; }
[ -z "$MYSQL_PASSWORD" ] && { echo "MYSQL_PASSWORD missing"; exit 1; }

# Use environment variables with defaults
MYSQL_PORT=${MYSQL_PORT:-3306}

# Create directories
mkdir -p /var/run/mysqld /var/log/mysql
chown -R mysql:mysql /var/run/mysqld /var/log/mysql /var/lib/mysql
chmod 777 /var/run/mysqld

# Initialize if volume/database is not present
if [ ! -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then
    echo "Initializing MariaDB..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db >/dev/null

    # Start temporary MariaDB server (without networking)
    mysqld --user=mysql --skip-networking --socket=/var/run/mysqld/mysqld.sock &
    PID=$!

    # Wait for temporary server to be ready
    for i in {30..1}; do
        if mysql --socket=/var/run/mysqld/mysqld.sock -uroot -e "SELECT 1" &>/dev/null; then
            break
        fi
        sleep 1
    done

    # Secure installation and create database/user
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

    # Stop temporary server
    kill $PID
    wait $PID 2>/dev/null || true
fi

echo "Starting MariaDB on port $MYSQL_PORT..."
exec mysqld --user=mysql --bind-address=0.0.0.0 --port=$MYSQL_PORT