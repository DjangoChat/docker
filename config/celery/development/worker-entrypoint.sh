#!/bin/sh

set -e

if [ "$(id -u)" = "0" ]; then
    mkdir -p /app/backend/htmlcov
    chmod -R 777 /app/backend || true
fi

check_db_running() {
    echo "Waiting for database to be ready..."
    python manage.py wait_db --timeout 90
}

start_worker() {
    echo "Starting Celery worker (queue=default, concurrency=2)..."
    exec python -m celery -A config worker \
        --loglevel=info \
        --concurrency=2 \
        --queues=default \
        --hostname=default-worker@%h \
        "$@"
}

main() {
    check_db_running
    start_worker
}

main "$@"
