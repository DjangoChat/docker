#!/bin/sh

set -e

# Celery Worker Entrypoint
# Runs Celery worker with configured settings for development

if [ "$(id -u)" = "0" ]; then
    mkdir -p /app/backend/htmlcov
    chmod -R 777 /app/backend || true
fi

check_db_running() {
    echo "Waiting for database to be ready..."
    python manage.py wait_db --timeout 90
}

start_worker() {
    echo "Starting Celery worker..."
    exec python -m celery -A config worker --loglevel=info --concurrency=1 "$@"
}

main() {
    check_db_running
    start_worker
}

main "$@"
