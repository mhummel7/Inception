# base image: penultimate stable (vorletzte stable version)
FROM debian:bookworm

# update, upgrade and install maria db and clean cache
RUN apt update && apt upgrade -y && \
    apt install -y mariadb-server mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# copy init script
COPY ./tools/init-db.sh /usr/local/bin/

# make script executable
RUN chmod +x /usr/local/bin/init-db.sh

# document internal port (does nothing, subject says 3306)
EXPOSE 3306

# set entrypoint and default cmd
ENTRYPOINT ["init-db.sh"]
CMD ["mariadbd", "--bind-address=0.0.0.0"]
