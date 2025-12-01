NAME=inception
COMPOSE=docker-compose -f srcs/docker-compose.yml
UID=$(shell id -u)
GID=$(shell id -g)
LOGIN=mhummel  # Ersetze durch deinen Login!
DATA_DIR=/home/$(LOGIN)/data

.DEFAULT_GOAL := up

all: env dirs up

env:
	@if [ ! -f srcs/.env ]; then \
		echo "DOMAIN_NAME=$(LOGIN).42.fr" > srcs/.env; \
		echo "# Füge hier weitere Vars hinzu (z.B. MYSQL_USER=...)" >> srcs/.env; \
	fi

dirs:
	@mkdir -p $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb

up:
	@echo "🚀 Starting containers..."
	@$(COMPOSE) up --build

down:
	@echo "🛑 Stopping containers..."
	@$(COMPOSE) down

re: down
	@echo "🔁 Rebuilding containers..."
	@$(COMPOSE) up --build

clean:
	@echo "🧹 Removing containers, networks and images..."
	@$(COMPOSE) down --rmi all

fclean: clean
	@echo "🔥 Removing everything including volumes..."
	@$(COMPOSE) down --rmi all -v
	@docker system prune --all --force --volumes
	@rm -rf $(DATA_DIR)

ps:
	@$(COMPOSE) ps

logs:
	@$(COMPOSE) logs -f
