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

set_up_stripe() {
  python manage.py check_stripe_secret --timeout 20
}

check_db_running() {
  echo "Waiting for database to be ready..."
  # First, resolve the database hostname to IP and cache it
  echo "Resolving database IP address..."
  DB_IP=$(python -c "import socket; print(socket.gethostbyname('db'))" 2>/dev/null)
  if [ -z "$DB_IP" ]; then
    echo "Failed to resolve 'db', will use hostname"
  else
    echo "Resolved 'db' to IP: $DB_IP"
    export POSTGRES_HOST="$DB_IP"
  fi
  
  # Give Docker DNS and network time to fully initialize
  sleep 5
  echo "Attempting database connection..."
  python manage.py wait_db --timeout 90
  # Extra grace period to let connections stabilize
  sleep 5
}

running_migrations() {
  echo "Running Django migrations..."
  # Add a small delay before migrations to ensure DNS is stable
  sleep 2
  
  python manage.py makemigrations --noinput
  python manage.py migrate --fake-initial --noinput
}

running_command_after_migrations() {
  echo "Running command for creating groups and assing permissions"

  python manage.py create_groups
  python manage.py create_currency
  python manage.py create_period
  python manage.py create_plan
  python manage.py create_price
}

running_tests() {
  echo "Running tests with coverage..."
  rm -f /app/backend/.coverage
  cd /app/backend
  PYTHONPATH=/app/backend/src:$PYTHONPATH pytest test --cov=src/apps --cov-report=term-missing --cov-report=html:htmlcov --cov-config=.coveragerc || true
  cd /app/backend/src
}

main () {
  set_up_stripe
  check_db_running
  running_migrations
  running_command_after_migrations

  echo "Starting server..."
  exec "$@"
}

main "$@"