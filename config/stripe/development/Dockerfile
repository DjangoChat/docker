FROM stripe/stripe-cli:latest

COPY docker/config/stripe/development/init-stripe-secret.sh /app/init-stripe-secret.sh
RUN chmod +x /app/init-stripe-secret.sh

ENTRYPOINT sh /app/init-stripe-secret.sh
