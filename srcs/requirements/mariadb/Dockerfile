FROM debian:bookworm

RUN apt update && apt upgrade -y && \
    apt install -y mariadb-server mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# Config + Init-Script reinkopieren (wir machen das später im Ordner conf + tools)
COPY ./tools/init-db.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/init-db.sh

EXPOSE 3306

# MariaDB als PID 1 starten (kein Hack!)
ENTRYPOINT ["init-db.sh"]
CMD ["mariadbd", "--bind-address=0.0.0.0"]