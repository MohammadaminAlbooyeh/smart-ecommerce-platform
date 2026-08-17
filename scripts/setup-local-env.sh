#!/usr/bin/env bash
set -euo pipefail

# In script sibling repo-haye service ro dar kenar-e meta-repo clone/build mikone.
# Estefade: ./scripts/setup-local-env.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PARENT_DIR="$(dirname "$ROOT_DIR")"

SERVICES=(
  "payment-switch-gateway"
  "order-service"
  "inventory-service"
  "cart-service"
  "product-search-engine"
  "recommendation_engine"
  "real_time_fraud_detection_system"
  "real_time_analytics_dashboard"
  "user-service"
)

echo "==> Sibling service repo-ha dar: $PARENT_DIR"

for service in "${SERVICES[@]}"; do
  service_path="$PARENT_DIR/$service"
  if [ -d "$service_path" ]; then
    echo "==> $service mojood ast, skip mishe."
  else
    echo "==> $service peida nashod. In repo ro dastan clone konid ya befazid be $PARENT_DIR."
  fi
done

echo "==> Baraye run kardan-e infrastructure (postgres, redis, kafka, elasticsearch):"
echo "    docker compose -f infrastructure/docker-compose/docker-compose.full.yml up -d"
