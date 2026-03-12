#!/bin/sh

set -e

if [ "$(id -u)" = "0" ]; then
  mkdir -p htmlcov
  chown -R django:django htmlcov
  chown -R django:django /app/backend
fi

if [ "$(id -u)" = "0" ]; then
  exec gosu django "$0" "$@"
fi

check_db_running() {
  python manage.py wait_db
}

running_migrations() {
  echo "Running Django migrations..."

  if [ "$ENV_TYPE" = "development" ]; then
    python manage.py makemigrations --noinput
  fi

  python manage.py migrate --fake-initial --noinput

  if [ "$ENV_TYPE" = "production" ]; then
    python manage.py collectstatic --noinput
  fi
}

running_command_after_migrations() {
  echo "Running command for creating groups and assing permissions"
  python manage.py create_groups.py
}

running_tests() {
  if [ "$ENV_TYPE" = "development" ] || [ "$ENV_TYPE" = "test" ]; then
    echo "Running tests with coverage..."
    rm -f /app/backend/.coverage
    cd /app/backend
    PYTHONPATH=/app/backend/src:$PYTHONPATH pytest test --cov=src/apps --cov-report=term-missing --cov-report=html:htmlcov --cov-config=.coveragerc || true
    cd /app/backend/src
  fi
}

main () {
  check_db_running
  running_migrations
  running_tests

  echo "Starting server..."
  exec "$@"
}

main