FROM debian:bookworm

# Installiere nginx, openssl und gettext-base (für envsubst)
RUN apt update && apt upgrade -y && \
    apt install -y nginx openssl gettext-base && \
    rm -rf /var/lib/apt/lists/*

# Generiere self-signed Zertifikat
RUN openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
    -keyout /etc/ssl/private/nginx.key \
    -out /etc/ssl/certs/nginx.crt \
    -subj "/C=DE/ST=BW/L=Heilbronn/O=42Heilbronn/CN=mhummel.42.fr"

# Kopiere Template und Start-Skript
COPY conf/nginx.conf.template /etc/nginx/sites-available/wordpress.template
COPY tools/start-nginx.sh /usr/local/bin/start-nginx.sh

# Mach Skript ausführbar
RUN chmod +x /usr/local/bin/start-nginx.sh

# Starte über unser Skript
CMD ["/usr/local/bin/start-nginx.sh"]