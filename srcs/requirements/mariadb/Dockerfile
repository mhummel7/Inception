# base image: penultimate stable
FROM debian:bookworm

# update, upgrade and install mariadb and clean cache
RUN apt update && apt upgrade -y && \
    apt install -y mariadb-server mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# Dynamischer Port als Build-Argument mit Default 3306
ARG MYSQL_PORT=3306

# Dokumentiere den Port dynamisch (wird in docker ps angezeigt)
EXPOSE $MYSQL_PORT

# copy init script
COPY ./tools/init-db.sh /usr/local/bin/

# make script executable
RUN chmod +x /usr/local/bin/init-db.sh

# set entrypoint and default cmd
ENTRYPOINT ["init-db.sh"]
CMD ["mariadbd", "--bind-address=0.0.0.0"]