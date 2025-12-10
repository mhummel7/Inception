#!/bin/bash
set -e

# Secrets
export MYSQL_PASSWORD=$(cat /run/secrets/mysql_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

# Warte auf MariaDB
until mariadb -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1" &>/dev/null; do sleep 1; done

# wp-cli absolut sicher installieren (offizielle GitHub-Release, immer gültig)
command -v wp >/dev/null || {
    wget -qO /usr/local/bin/wp https://github.com/wp-cli/wp-cli/releases/download/v2.11.0/wp-cli-2.11.0.phar
    chmod +x /usr/local/bin/wp
}

# WordPress einrichten
cd /var/www/wordpress

if [ ! -f wp-config.php ]; then
    wp config create --dbname="$MYSQL_DATABASE" --dbuser="$MYSQL_USER" --dbpass="$MYSQL_PASSWORD" --dbhost=mariadb --allow-root --force
    wp core install --url="$WP_URL" --title="$WP_TITLE" --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASSWORD" --admin_email="$WP_ADMIN_EMAIL" --allow-root
    wp user create "$WP_USER" "$WP_USER_EMAIL" --role=author --user_pass="$WP_USER_PASSWORD" --allow-root
    chown -R www-data:www-data .
fi

# PHP-FPM sauber starten
rm -f /run/php/php8.2-fpm.pid 2>/dev/null
exec /usr/sbin/php-fpm8.2 --nodaemonize