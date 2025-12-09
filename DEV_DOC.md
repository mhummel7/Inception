# Developer Documentation

This document guides developers on setting up, building, and managing the Inception project from scratch.

## Environment Setup
1. **Prerequisites**:
   - Fresh Debian VM (e.g., Bookworm).
   - Install Docker: Follow official docs (apt repo method: add key, repo, install docker-ce docker-compose-plugin).
   - Install Make: `sudo apt install make`.
   - Create data dir: `mkdir -p /home/mhummel/data/{db,wordpress}`.
   - Clone repo: `git clone <repo> && cd inception`.

2. **Configuration Files**:
   - `.env` in `srcs/`: Fill vars (DOMAIN_NAME=mhummel.42.fr, MYSQL_*, WP_* – generate strong PW if needed).
   - Secrets: Optional in `secrets/` (e.g., db_password.txt) – ignored in Git.
   - Hosts: Add "127.0.0.1 mhummel.42.fr" to `/etc/hosts`.

3. **Secrets**: Use .env for dev (env_file in compose). For prod: Docker secrets with file refs.

## Building and Launching
- **Full Build**: `make all` – Builds images, starts stack.
- **Quick Start**: `make up` – Starts from existing images.
- **Makefile Targets**:
  - `make down`: Stop containers.
  - `make re`: Down + full rebuild.
  - `make clean`: Down + remove images (--rmi all).
  - `make fclean`: Clean + remove volumes (-v).
  - `make ps`: List containers.
  - `make logs`: Tail logs from services.

## Managing Containers and Volumes
- **Commands**:
  - Inspect: `docker inspect <container>` (e.g., wordpress).
  - Exec: `docker exec -it mariadb mysql -u root -p` (DB shell).
  - Volumes: Persistent in `/home/mhummel/data/` (bind mounts). List: `docker volume ls`.
- **Data Persistence**: DB data in `/home/mhummel/data/db`, WP files in `/home/mhummel/data/wordpress` – survives restarts, but fclean deletes.

## Project Data Storage
- **Containers**: Ephemeral (recreated on build).
- **Volumes**: Bind mounts to host for persistence (edit files directly on host).
- **Logs**: In containers (view with `make logs`); no persistent logs configured.

For user guide, see USER_DOC.md.