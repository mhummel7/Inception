FROM debian:bookworm

RUN apt update && apt upgrade -y && \
    apt install -y php-fpm php-mysql php-cli wget curl mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# PHP-FPM korrekt konfigurieren (Debian Bookworm)
RUN sed -i "s|listen =.*|listen = 9000|g" /etc/php/*/fpm/pool.d/www.conf && \
    sed -i "s|;clear_env =.*|clear_env = no|g" /etc/php/*/fpm/pool.d/www.conf && \
    sed -i "s|;listen.owner =.*|listen.owner = www-data|g" /etc/php/*/fpm/pool.d/www.conf && \
    sed -i "s|;listen.group =.*|listen.group = www-data|g" /etc/php/*/fpm/pool.d/www.conf && \
    sed -i "s|;listen.mode =.*|listen.mode = 0660|g" /etc/php/*/fpm/pool.d/www.conf

# Verzeichnis anlegen + WordPress runterladen
RUN mkdir -p /var/www && \
    curl -o /tmp/wordpress.tar.gz -SL https://wordpress.org/latest.tar.gz && \
    tar -xzf /tmp/wordpress.tar.gz -C /var/www/ && \
    rm /tmp/wordpress.tar.gz && \
    chown -R www-data:www-data /var/www/wordpress

COPY ./tools/setup-wp.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup-wp.sh

EXPOSE 9000

ENTRYPOINT ["setup-wp.sh"]