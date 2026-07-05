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

  python manage.py wait_db --timeout 90
  sleep 5
}

running_migrations() {
  echo "Running Django migrations..."
  
  python manage.py makemigrations --noinput
  python manage.py migrate --fake-initial --noinput
}

running_command_after_migrations() {
  echo "Running command for creating groups and assing permissions"

  # SET DEFAULT DATA
  python manage.py create_groups
  python manage.py create_currency
  python manage.py create_period
  python manage.py create_plan
  python manage.py create_price
  python manage.py create_feature
  python manage.py create_quota
  python manage.py create_quota_plan
  python manage.py create_nature
  python manage.py create_policies_rules
  python manage.py create_participant_agent
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