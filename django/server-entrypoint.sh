#!/bin/sh

set -e

echo "Running Django migrations..."

python manage.py wait-db

if [ "$ENV_TYPE" = "development" ]; then
  python manage.py makemigrations --noinput
fi

python manage.py migrate --fake-initial --noinput

if [ "$ENV_TYPE" = "production" ]; then
  python manage.py collectstatic --noinput
fi

echo "Starting server..."
exec "$@"