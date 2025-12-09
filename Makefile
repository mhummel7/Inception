# Inception Makefile - Ohne docker system prune (nur compose-Cleanup)
COMPOSE_FILE = srcs/docker-compose.yml

all:
	docker compose -f $(COMPOSE_FILE) up --build -d

up:
	docker compose -f $(COMPOSE_FILE) up -d

down:
	docker compose -f $(COMPOSE_FILE) down

re: down
	$(MAKE) all

clean:
	docker compose -f $(COMPOSE_FILE) down --rmi all

fclean: clean
	docker compose -f $(COMPOSE_FILE) down --rmi all -v

# Hilfs-Targets
ps:
	docker ps -a

logs:
	docker logs mariadb --tail 20
	docker logs wordpress --tail 20
	docker logs nginx --tail 20

.PHONY: all up down re clean fclean ps logs