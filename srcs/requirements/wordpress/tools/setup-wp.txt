#!/bin/bash
set -e

# Secrets auslesen
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password 2>/dev/null || echo "")
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password 2>/dev/null || echo "")

[ -z "$WP_ADMIN_PASSWORD" ] && { echo "wp_admin_password secret missing"; exit 1; }
[ -z "$WP_USER_PASSWORD" ] && { echo "wp_user_password secret missing"; exit 1; }

echo "Waiting for MariaDB..."
for i in {1..30}; do
    if mariadb -h mariadb -P 3306 -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1" &>/dev/null; then
        echo "MariaDB ready!"
        break
    fi
    sleep 2
done
[ $i -eq 30 ] && { echo "MariaDB unreachable"; exit 1; }

WP_PATH="/var/www/wordpress"

# wp-cli falls nötig
[ ! -f /usr/local/bin/wp ] && {
    curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/wp-cli/v2.10.0/wp-cli.phar
    chmod +x /usr/local/bin/wp
}

if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "First-time WordPress setup..."

    wp config create --dbname="$MYSQL_DATABASE" \
                     --dbuser="$MYSQL_USER" \
                     --dbpass="$MYSQL_PASSWORD" \
                     --dbhost=mariadb \
                     --path="$WP_PATH" \
                     --allow-root --force

    wp core install --url="$WP_URL" \
                    --title="$WP_TITLE" \
                    --admin_user="$WP_ADMIN_USER" \
                    --admin_password="$WP_ADMIN_PASSWORD" \
                    --admin_email="$WP_ADMIN_EMAIL" \
                    --path="$WP_PATH" \
                    --allow-root

    wp user create "$WP_USER" "$WP_USER_EMAIL" \
                   --role=author \
                   --user_pass="$WP_USER_PASSWORD" \
                   --path="$WP_PATH" \
                   --allow-root

    chown -R www-data:www-data "$WP_PATH"
fi

echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm8.2 --nodaemonize