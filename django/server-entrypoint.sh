#!/bin/sh

set -e

# Fix permissions on mounted volumes
if [ "$(id -u)" = "0" ]; then
  mkdir -p htmlcov
  chown -R django:django htmlcov
  chown -R django:django /app/backend
fi

echo "Running Django migrations..."

# Switch to django user and run commands
if [ "$(id -u)" = "0" ]; then
  exec gosu django "$0" "$@"
fi

python manage.py wait_db

if [ "$ENV_TYPE" = "development" ]; then
  python manage.py makemigrations --noinput
fi

python manage.py migrate --fake-initial --noinput

if [ "$ENV_TYPE" = "production" ]; then
  python manage.py collectstatic --noinput
fi

# Run tests in development/test environments
if [ "$ENV_TYPE" = "development" ] || [ "$ENV_TYPE" = "test" ]; then
  echo "Running tests with coverage..."
  rm -f /app/backend/.coverage
  cd /app/backend
  PYTHONPATH=/app/backend/src:$PYTHONPATH pytest test --cov=src/apps --cov-report=term-missing --cov-report=html:htmlcov --cov-config=.coveragerc || true
  cd /app/backend/src
fi

echo "Starting server..."
exec "$@"