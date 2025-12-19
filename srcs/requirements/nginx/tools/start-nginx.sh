#!/bin/bash
set -e

# Wichtige Defaults explizit setzen
NGINX_INTERNAL_PORT=${NGINX_INTERNAL_PORT:-443}
WP_FPM_PORT=${WP_FPM_PORT:-9000}

# Variablen exportieren, damit envsubst sie sieht
export NGINX_INTERNAL_PORT WP_FPM_PORT

# Template ersetzen
envsubst '${NGINX_INTERNAL_PORT} ${WP_FPM_PORT}' < /etc/nginx/sites-available/wordpress.template > /etc/nginx/sites-available/wordpress

# Default site entfernen
rm -f /etc/nginx/sites-enabled/default

# Site aktivieren
ln -sf /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/wordpress

# Nginx starten (Fehler werden jetzt sichtbar)
exec nginx -g "daemon off;"