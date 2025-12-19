# Base image: Debian Bookworm (penultimate stable)
FROM debian:bookworm

# Update, upgrade, install PHP-FPM and deps, clean cache
RUN apt update && apt upgrade -y && \
    apt install -y php-fpm php-mysql php-cli wget curl mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# Dynamischer Port als Build-Argument mit Default 9000
ARG WP_FPM_PORT=9000

# Dokumentiere den Port dynamisch (wird in docker ps angezeigt)
EXPOSE $WP_FPM_PORT

# Configure PHP-FPM pool – wir entfernen das harte sed, 
# weil wir den Port jetzt zur Laufzeit in setup-wp.sh setzen
# (flexibler – kein Rebuild nötig bei Port-Änderung)
# Aber: clear_env=no bleibt sinnvoll
RUN sed -i "s|;clear_env =.*|clear_env = no|g" /etc/php/*/fpm/pool.d/www.conf && \
    sed -i "s|;listen.owner =.*|listen.owner = www-data|g" /etc/php/*/fpm/pool.d/www.conf && \
    sed -i "s|;listen.group =.*|listen.group = www-data|g" /etc/php/*/fpm/pool.d/www.conf && \
    sed -i "s|;listen.mode =.*|listen.mode = 0660|g" /etc/php/*/fpm/pool.d/www.conf

# Create dir, download/unpack WordPress, chown
RUN mkdir -p /var/www && \
    curl -o /tmp/wordpress.tar.gz -SL https://wordpress.org/latest.tar.gz && \
    tar -xzf /tmp/wordpress.tar.gz -C /var/www/ && \
    rm /tmp/wordpress.tar.gz && \
    chown -R www-data:www-data /var/www/wordpress

# Copy setup script
COPY ./tools/setup-wp.sh /usr/local/bin/

# Make script executable
RUN chmod +x /usr/local/bin/setup-wp.sh

# Set entrypoint
ENTRYPOINT ["setup-wp.sh"]