#!/usr/bin/env bash
set -euo pipefail

# Demo data seed mikone baraye stack-e mahali.
# Zarfi: service-ha bayad up bashan (docker compose up + run-e service-ha).
# Estefade: ./scripts/seed-demo-data.sh

USER_URL="${USER_SERVICE_URL:-http://localhost:8081}"
CART_URL="${CART_SERVICE_URL:-http://localhost:8082}"
ORDER_URL="${ORDER_SERVICE_URL:-http://localhost:8083}"
INVENTORY_URL="${INVENTORY_SERVICE_URL:-http://localhost:8084}"
SEARCH_URL="${SEARCH_ENGINE_URL:-http://localhost:8086}"

DEMO_USER="demo_user"
DEMO_PASSWORD="demo_password123"

wait_for() {
  local url="$1"
  local name="$2"
  echo "==> Waiting for $name ($url)..."
  for i in $(seq 1 30); do
    if curl -sf -o /dev/null "$url" 2>/dev/null; then
      echo "    $name is up."
      return 0
    fi
    sleep 1
  done
  echo "    WARNING: $name did not respond in time, continuing anyway."
}

seed_user() {
  echo "==> Seeding demo user: $DEMO_USER"
  curl -sf -X POST "$USER_URL/api/auth/register" \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"$DEMO_USER\",\"email\":\"demo@example.com\",\"password\":\"$DEMO_PASSWORD\",\"firstName\":\"Demo\",\"lastName\":\"User\"}" \
    || echo "    (user may already exist — skipping)"
}

seed_inventory() {
  echo "==> Seeding warehouse and stock"
  WAREHOUSE_ID=$(curl -sf -X POST "$INVENTORY_URL/api/inventory/warehouses" \
    -H "Content-Type: application/json" \
    -d '{"name":"Main Warehouse","location":"Tehran"}' | python3 -c "import sys,json;print(json.load(sys.stdin).get('id','1'))" 2>/dev/null || echo 1)

  for p in p1 p2 p3; do
    curl -sf -X POST "$INVENTORY_URL/api/inventory/items" \
      -H "Content-Type: application/json" \
      -d "{\"productId\":\"$p\",\"warehouseId\":$WAREHOUSE_ID,\"quantity\":100}" || true
  done
  echo "    Seeded stock for p1, p2, p3 (warehouse $WAREHOUSE_ID)"
}

seed_cart() {
  echo "==> Seeding cart for $DEMO_USER"
  for item in '{"productId":"p1","name":"Laptop","unitPrice":1200,"quantity":1}' \
              '{"productId":"p2","name":"Mouse","unitPrice":25,"quantity":2}'; do
    curl -sf -X POST "$CART_URL/api/cart/items" \
      -H "X-User-Id: $DEMO_USER" -H "Content-Type: application/json" \
      -d "$item" || true
  done
  echo "    Cart ready. Checkout: POST $CART_URL/api/cart/checkout with X-User-Id: $DEMO_USER"
}

wait_for "$USER_URL/api/auth/login" "user-service"
wait_for "$INVENTORY_URL/api/inventory/items" "inventory-service"
wait_for "$CART_URL/api/cart/total" "cart-service"
wait_for "$ORDER_URL/api/orders" "order-service"
wait_for "$SEARCH_URL/api/search" "product-search-engine"

seed_user
seed_inventory
seed_cart

echo "==> Demo data seeding finished."
echo "    Login: $DEMO_USER / $DEMO_PASSWORD"
