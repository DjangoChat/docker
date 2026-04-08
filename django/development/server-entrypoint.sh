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

  python manage.py makemigrations --noinput
  python manage.py migrate --fake-initial --noinput
}

running_command_after_migrations() {
  echo "Running command for creating groups and assing permissions"

  python manage.py create_groups
  # python manage.py create_currency
  # python manage.py create_period
  # python manage.py create_plan
  # python manage.py create_price
}

running_tests() {
  echo "Running tests with coverage..."
  rm -f /app/backend/.coverage
  cd /app/backend
  PYTHONPATH=/app/backend/src:$PYTHONPATH pytest test --cov=src/apps --cov-report=term-missing --cov-report=html:htmlcov --cov-config=.coveragerc || true
  cd /app/backend/src
}

main () {
  check_db_running
  running_migrations
  running_command_after_migrations
  # running_tests

  echo "Starting server..."
  exec "$@"
}

main "$@"