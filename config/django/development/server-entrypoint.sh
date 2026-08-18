#!/bin/sh

set -e

# For mounted volumes in development, run as root to avoid permission issues
# In production, the container runs as 'django' user (see Dockerfile)
if [ "$(id -u)" = "0" ]; then
    mkdir -p /app/backend/htmlcov
    chmod -R 777 /app/backend || true
    # Don't drop to django user for dev - run commands as root
fi

check_db_running() {
    echo "Waiting for database to be ready..."
    python manage.py wait_db --timeout 90
}

run_migrations() {
    echo "Running Django migrations..."
    python manage.py makemigrations
    python manage.py migrate --noinput
}

main() {
    check_db_running
    run_migrations

    echo "Starting server..."
    exec "$@"
}

main "$@"