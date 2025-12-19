#!/bin/bash
set -e # Exit on error

# Load secrets
export MYSQL_PASSWORD=$(cat /run/secrets/mysql_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

# Use environment variables with defaults
MYSQL_PORT=${MYSQL_PORT:-3306}
WP_FPM_PORT=${WP_FPM_PORT:-9000}

# Wait for MariaDB on the correct port
echo "Waiting for MariaDB on mariadb:$MYSQL_PORT ..."
until mariadb -h mariadb -P "$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --protocol=TCP -e "SELECT 1" &>/dev/null; do
    sleep 1
done
echo "MariaDB is up!"

# Install wp-cli if missing
command -v wp >/dev/null || {
    echo "Installing wp-cli..."
    wget -qO /usr/local/bin/wp https://github.com/wp-cli/wp-cli/releases/download/v2.11.0/wp-cli-2.11.0.phar
    chmod +x /usr/local/bin/wp
}

# Configure PHP-FPM to listen on the desired port (runtime!)
echo "Configuring PHP-FPM to listen on port $WP_FPM_PORT ..."
sed -i "s|listen = .*|listen = $WP_FPM_PORT|g" /etc/php/*/fpm/pool.d/www.conf

# Go to WordPress directory
cd /var/www/wordpress

# Only configure and install if wp-config.php does not exist yet
if [ ! -f wp-config.php ]; then
    echo "Creating wp-config.php..."
    wp config create --dbname="$MYSQL_DATABASE" \
                     --dbuser="$MYSQL_USER" \
                     --dbpass="$MYSQL_PASSWORD" \
                     --dbhost="mariadb:$MYSQL_PORT" \
                     --allow-root --force

    echo "Installing WordPress core..."
    wp core install --url="$WP_URL" \
                    --title="$WP_TITLE" \
                    --admin_user="$WP_ADMIN_USER" \
                    --admin_password="$WP_ADMIN_PASSWORD" \
                    --admin_email="$WP_ADMIN_EMAIL" \
                    --allow-root

    echo "Creating additional user..."
    wp user create "$WP_USER" "$WP_USER_EMAIL" --role=author --user_pass="$WP_USER_PASSWORD" --allow-root

    chown -R www-data:www-data /var/www/wordpress
fi

# Clean up possible old PID file
rm -f /run/php/php*-fpm.pid 2>/dev/null

echo "Starting PHP-FPM on port $WP_FPM_PORT ..."
exec /usr/sbin/php-fpm8.2 --nodaemonize