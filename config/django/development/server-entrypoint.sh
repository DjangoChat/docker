#!/bin/sh

set -e

if [ "$(id -u)" = "0" ]; then
    mkdir -p /app/backend/htmlcov
    chown -R django:django /app/backend
    exec gosu django "$0" "$@"
fi

check_db_running() {
    echo "Waiting for database to be ready..."
    python manage.py wait_db --timeout 90
}

run_migrations() {
    echo "Running Django migrations..."
    python manage.py migrate --noinput
}

main() {
    check_db_running
    run_migrations

    echo "Starting server..."
    exec "$@"
}

main "$@"