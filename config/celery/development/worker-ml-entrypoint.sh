#!/bin/sh

set -e

# ML Worker Entrypoint
# Dedicated Celery worker for heavy ML tasks (embeddings, sentiment, emotion, topics).
# Runs with concurrency=1 on the 'ml' queue so only one ML task runs at a time,
# keeping model memory usage bounded and preventing CPU/RAM spikes.

if [ "$(id -u)" = "0" ]; then
    mkdir -p /app/backend/htmlcov
    chmod -R 777 /app/backend || true
fi

check_db_running() {
    echo "Waiting for database to be ready..."
    python manage.py wait_db --timeout 90
}

start_ml_worker() {
    echo "Starting Celery ML worker (queue=ml, concurrency=1)..."
    exec python -m celery -A config worker \
        --loglevel=info \
        --concurrency=1 \
        --queues=ml \
        --hostname=ml-worker@%h \
        "$@"
}

main() {
    check_db_running
    start_ml_worker
}

main "$@"
