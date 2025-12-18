# base image: penultimate stable (vorletzte stable version)
FROM debian:bookworm

# update, upgrade and install nginx&openssl and clean cache
RUN apt update && apt upgrade -y && \
    apt install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# Generate self-signed cert (TLS 1.2/1.3, 365 days, RSA 4096)
RUN openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
    -keyout /etc/ssl/private/nginx.key \
    -out /etc/ssl/certs/nginx.crt \
    -subj "/C=DE/ST=BW/L=Heilbronn/O=42Heilbronn/CN=mhummel.42.fr"

# Copy Nginx config
COPY ./conf/nginx.conf /etc/nginx/sites-available/wordpress

# Link config, remove default
RUN ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/ && \
    rm /etc/nginx/sites-enabled/default

# Document internal port
EXPOSE 443

# Nginx als PID 1 starten
CMD ["nginx", "-g", "daemon off;"]
