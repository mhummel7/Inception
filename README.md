*This project has been created as part of the 42 curriculum by mhummel.*

## Description

### Project Overview
Inception is a system administration exercise focused on containerization using Docker. The goal is to deploy a fully functional WordPress website with a MariaDB database and Nginx as a reverse proxy, all virtualized in custom Docker images. This setup demonstrates key Docker concepts like multi-container orchestration, persistent storage, and secure communication via TLS.

The stack includes:
- **MariaDB**: Handles the database for WordPress (MySQL-compatible).
- **WordPress**: Runs with PHP-FPM for dynamic content generation.
- **Nginx**: Serves as the entry point with TLS termination and fastcgi proxying to WordPress.

This project broadens knowledge of Docker by requiring custom Dockerfiles, a docker-compose.yml for orchestration, and a Makefile for build/run management. It emphasizes best practices like no infinite loops, proper PID 1 handling, and secure credential management using Docker Secrets.

### Docker Usage and Design Choices
Docker is used to containerize each service (MariaDB, WordPress, Nginx), allowing isolated, reproducible environments. The project sources include custom Dockerfiles (based on Debian Bookworm), scripts for initialization (init-db.sh, setup-wp.sh), and configuration files (nginx.conf, php-fpm pool adjustments). The docker-compose.yml defines services, networks, volumes, and secrets for seamless integration.

#### Virtual Machines vs Docker
| Aspect              | Virtual Machines (e.g., VirtualBox) | Docker                          |
|---------------------|-------------------------------------|---------------------------------|
| **Overhead**       | High (full OS emulation)           | Low (containerized processes)   |
| **Portability**    | Good (VM images)                   | Excellent (images across hosts) |
| **Startup Time**   | Slow (boot OS)                     | Fast (instant container spin-up)|
| **Resource Use**   | High (dedicated kernel/OS)         | Shared kernel, efficient        |
| **Use Case**       | Full isolation (e.g., different OS)| Microservices (e.g., this stack)|

Docker is chosen for Inception due to its lightweight nature and focus on application layers, aligning with the project's containerization goals.

#### Secrets vs Environment Variables
| Aspect              | Docker Secrets                     | Environment Variables (.env)    |
|---------------------|------------------------------------|---------------------------------|
| **Security**       | Encrypted, mounted as read-only files | Passed at runtime, visible in processes |
| **Persistence**    | Managed by Docker Swarm/Compose    | Reloaded per container start    |
| **Ease of Use**    | More complex (file refs in yml)    | Simple (env_file in compose)    |
| **Use Case**       | Production (sensitive data)        | Development (quick prototyping) |

Docker Secrets are used here for all passwords (mysql_*, wp_*_password) via files in srcs/secrets/, mounted in compose.yml and read in init scripts (e.g., cat /run/secrets/...). Environment variables via .env are limited to non-sensitive data (e.g., DOMAIN_NAME). Secrets are ignored in .gitignore for security.

#### Docker Network vs Host Network
| Aspect              | Docker Network (bridge)            | Host Network                    |
|---------------------|------------------------------------|---------------------------------|
| **Isolation**      | High (internal communication only) | Low (shares host's network stack)|
| **Port Exposure**  | Explicit (ports: in compose)       | Direct host ports               |
| **Security**       | Better (firewall between containers)| Direct (exposed to host)       |
| **Use Case**       | Multi-container apps (this project)| Single-container, host-integrated|

A custom bridge network ("inception") is used for isolated inter-service communication (e.g., wordpress:9000 from nginx), enhancing security.

#### Docker Volumes vs Bind Mounts
| Aspect              | Docker Volumes                     | Bind Mounts                     |
|---------------------|------------------------------------|---------------------------------|
| **Performance**    | Good (managed storage)             | Best (direct host FS access)    |
| **Portability**    | High (abstracted from host)        | Low (host-path dependent)       |
| **Management**     | Docker handles creation            | Manual host dir creation        |
| **Use Case**       | Portable data (e.g., DB backups)   | Dev/debug (edit host files)     |

Bind mounts are used (/home/mhummel/data/db and /home/mhummel/data/wordpress) for easy host access and persistence across VM reboots, ideal for development.

## Instructions
1. **Prerequisites**: Debian-based VM with Docker and Docker Compose installed (see DEV_DOC.md for setup).
2. **Clone Repo**: `git clone <your-repo-url> && cd inception`.
3. **Set Environment**: Copy `.env.example` to `srcs/.env` and fill in non-sensitive values (e.g., DOMAIN_NAME=mhummel.42.fr).
4. **Create Secrets**: In `srcs/secrets/`, create files like mysql_password (e.g., `echo -n "strongpw" > srcs/secrets/mysql_password`), set `chmod 600 srcs/secrets/*`.
5. **Build and Run**: `make all` (or `make up` for quick start).
6. **Access Site**: https://mhummel.42.fr (self-signed cert – proceed anyway). Admin: https://mhummel.42.fr/wp-admin.
7. **Stop**: `make down`.
8. **Clean**: `make clean` (removes images) or `make fclean` (full reset, including volumes).

## Resources
- **Docker Documentation**: [Official Docker Docs](https://docs.docker.com/) – Used for best practices (PID 1, no infinite loops, secrets).
- **WordPress Codex**: [WP Installation Guide](https://wordpress.org/documentation/article/how-to-install-wordpress/) – For wp-cli commands.
- **Nginx TLS Setup**: [Nginx HTTPS Guide](https://docs.nginx.com/nginx/admin-guide/security-controls/securing-http-traffic-to-upstream-servers/) – For self-signed certs.
- **MariaDB Init**: [MariaDB Docker Examples](https://hub.docker.com/_/mariadb) – Adapted for custom init scripts.
- **AI Usage**: Grok (xAI) assisted in debugging Docker scripts (e.g., init-db.sh waiting loops, PHP-FPM paths, secrets integration) and generating comparisons (VMs vs Docker). No code generation – all custom-written by me. Tools used: Code execution for testing bash snippets.

For more, see [42 Intra Project Page](https://intra.42.fr/projects/inception).
