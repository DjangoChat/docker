#!/bin/sh

set -e

# Celery Beat Entrypoint
# Runs Celery beat scheduler for periodic tasks in development

if [ "$(id -u)" = "0" ]; then
    mkdir -p /app/backend/htmlcov
    chmod -R 777 /app/backend || true
fi

check_db_running() {
    echo "Waiting for database to be ready..."
    python manage.py wait_db --timeout 90
}

start_beat() {
    echo "Starting Celery beat scheduler..."
    exec python -m celery -A config beat --loglevel=info "$@"
}

main() {
    check_db_running
    start_beat
}

main "$@"
