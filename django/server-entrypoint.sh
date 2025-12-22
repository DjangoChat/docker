#!/bin/sh

until cd /app/backend/src
do
    echo "Waiting for server volume..."
done

until python manage.py makemigrations
do
    echo "Creating migration files ..."
    sleep 2
done

until python manage.py migrate --fake-initial
do
    echo "Migrating tables to database ..."
    sleep 2
done

until python manage.py collectstatic --noinput
do
    echo "Collecting static content ..."
    sleep 2
done

exec python manage.py runserver 0.0.0.0:8000