#!/bin/sh

set -e

# Flower Entrypoint
# Runs Celery Flower monitoring tool in development

if [ "$(id -u)" = "0" ]; then
    mkdir -p /app/backend/htmlcov
    chmod -R 777 /app/backend || true
fi

check_rabbitmq() {
    echo "Waiting for RabbitMQ to be ready..."
    # Simple check - can be enhanced based on your needs
    sleep 2
}

start_flower() {
    echo "Starting Celery Flower monitoring tool..."
    exec python -m celery -A config flower --address=0.0.0.0 --port=5555 "$@"
}

main() {
    check_rabbitmq
    start_flower
}

main "$@"
