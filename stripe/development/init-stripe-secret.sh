#!/bin/sh

# Stripe CLI initialization script
# Captures the webhook signing secret from stripe-cli output and saves it to a shared volume

set -e

echo "Starting Stripe CLI and capturing webhook secret..."

# Run stripe-cli and capture output
stripe listen --api-key "$STRIPE_API_KEY" --forward-to web:8000/stripe/webhook --skip-verify 2>&1 | while IFS= read -r line; do
  echo "$line"
  
  # Extract webhook secret from the output
  # Pattern: "Your webhook signing secret is whsec_..."
  if echo "$line" | grep -q 'whsec_'; then
    secret=$(echo "$line" | grep -o 'whsec_[a-zA-Z0-9]*')
    echo "✓ Found webhook secret: $secret"
    
    # Write to shared volume so web container can read it
    mkdir -p /stripe-secrets
    echo "$secret" > /stripe-secrets/webhook_secret
    chmod 644 /stripe-secrets/webhook_secret
    echo "✓ Webhook secret saved to /stripe-secrets/webhook_secret"
  fi
done &

# Keep the process running
wait
