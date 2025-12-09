# User Documentation

This document is for end users or administrators to manage the Inception WordPress stack.

## Services Provided
The stack deploys a secure WordPress site with:
- **Nginx**: Reverse proxy on HTTPS (Port 443, TLS only – no HTTP).
- **WordPress**: Dynamic CMS with PHP-FPM (two users: admin "mhummel" and author "user").
- **MariaDB**: Backend database for WordPress (persistent data).

The site is accessible at https://mhummel.42.fr (self-signed cert – accept warning).

## Starting and Stopping
- **Start**: Run `make all` (first time) or `make up` (quick restart) in the project root.
- **Stop**: Run `make down`.
- **Check Status**: `make ps` (lists containers) or `docker ps`.

## Accessing the Website
- **Frontend**: https://mhummel.42.fr – Browse/create posts.
- **Admin Panel**: https://mhummel.42.fr/wp-admin – Manage site.
  - Users: Admin (full access), Author (posts only).
- **In VM**: Use `curl -k https://mhummel.42.fr` for CLI test (ignores SSL).

## Managing Credentials
- Credentials are in `srcs/.env` (never commit – see .gitignore).
  - Change passwords: Edit .env, then `make re`.
  - Database: Root PW in .env (MYSQL_ROOT_PASSWORD), WP DB user "mhummel" (MYSQL_USER).

## Checking Services
- **Logs**: `make logs` – Last 20 lines from each container (mariadb, wordpress, nginx).
- **Health**: `docker ps` – All should be "Up".
- **Data Location**: Persistent in `/home/mhummel/data/` (db/ for MariaDB, wordpress/ for WP files).
- **Restart Test**: `docker kill <container-id>` – Should auto-restart (restart: always).
- **Troubleshoot**: If 502 error, check logs for PHP-FPM/DB connection issues.

For developer setup, see DEV_DOC.md.