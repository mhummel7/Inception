FROM debian:bookworm

RUN apt update && apt upgrade -y && \
    apt install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# TLSv1.2 + TLSv1.3 only + selbstsigniertes Zertifikat
RUN openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
    -keyout /etc/ssl/private/nginx.key \
    -out /etc/ssl/certs/nginx.crt \
    -subj "/C=DE/ST=NRW/L=mhummel/O=mhummel/CN=mhummel.42.fr"

COPY ./conf/nginx.conf /etc/nginx/sites-available/wordpress
RUN ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/ && \
    rm /etc/nginx/sites-enabled/default

EXPOSE 443

# Nginx als PID 1 starten
CMD ["nginx", "-g", "daemon off;"]