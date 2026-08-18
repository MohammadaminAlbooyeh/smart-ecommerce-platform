#!/usr/bin/env bash
set -euo pipefail

# End-to-end test: cart checkout -> order saga -> inventory reserve -> payment -> CONFIRMED,
# plus a fraud-flag branch that should cancel the order with compensation.
# Zarfi: infra (docker compose up) + service-ha run hastan. Baraye payment va fraud, az
# kafka-console-producer tooye container-e kafka estefade mikonim.
# Estefade: ./scripts/test-e2e.sh

USER_URL="${USER_SERVICE_URL:-http://localhost:8081}"
CART_URL="${CART_SERVICE_URL:-http://localhost:8082}"
ORDER_URL="${ORDER_SERVICE_URL:-http://localhost:8083}"
INVENTORY_URL="${INVENTORY_SERVICE_URL:-http://localhost:8084}"
KAFKA_SERVICE="${KAFKA_SERVICE:-kafka}"
KAFKA_BOOTSTRAP="${KAFKA_BOOTSTRAP:-kafka:9092}"

DEMO_USER="e2e_user"
DEMO_PASSWORD="e2e_password123"

fail() {
  echo "E2E FAILED: $1"
  exit 1
}

log() {
  echo "==> $1"
}

wait_status() {
  local order_id="$1"
  local expected="$2"
  local attempts="${3:-40}"
  for i in $(seq 1 "$attempts"); do
    status=$(curl -sf "$ORDER_URL/api/orders/$order_id" | python3 -c "import sys,json;print(json.load(sys.stdin)['status'])" 2>/dev/null || echo "")
    if [ "$status" = "$expected" ]; then
      echo "    order $order_id -> $expected"
      return 0
    fi
    sleep 1
  done
  fail "order $order_id not in state $expected (last: ${status:-none})"
}

wait_for() {
  local url="$1"
  local name="$2"
  log "Waiting for $name ($url)..."
  for i in $(seq 1 40); do
    if curl -sf -o /dev/null "$url" 2>/dev/null; then
      return 0
    fi
    sleep 1
  done
  fail "$name did not start"
}

find_latest_order() {
  local user="$1"
  for i in $(seq 1 20); do
    local order_id
    order_id=$(curl -sf "$ORDER_URL/api/orders?userId=$user" 2>/dev/null | python3 -c "
import sys,json
try:
    orders=json.load(sys.stdin)
    print(orders[0]['orderId'] if orders else '')
except Exception:
    print('')
")
    if [ -n "$order_id" ]; then
      echo "$order_id"
      return 0
    fi
    sleep 1
  done
  return 1
}

wait_for "$CART_URL/api/cart/total" "cart-service"
wait_for "$ORDER_URL/api/orders?userId=x" "order-service"
wait_for "$INVENTORY_URL/api/inventory/items" "inventory-service"
wait_for "$USER_URL/api/auth/login" "user-service"

log "Seeding demo user"
curl -sf -X POST "$USER_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$DEMO_USER\",\"email\":\"e2e@example.com\",\"password\":\"$DEMO_PASSWORD\"}" >/dev/null 2>&1 \
  || true

log "Seeding warehouse + stock"
WAREHOUSE_ID=$(curl -sf -X POST "$INVENTORY_URL/api/inventory/warehouses" \
  -H "Content-Type: application/json" \
  -d '{"name":"E2E WH","location":"Tehran"}' | python3 -c "import sys,json;print(json.load(sys.stdin)['id'])")
curl -sf -X POST "$INVENTORY_URL/api/inventory/items" \
  -H "Content-Type: application/json" \
  -d "{\"productId\":\"p1\",\"warehouseId\":$WAREHOUSE_ID,\"quantity\":100}" >/dev/null

log "Filling cart"
curl -sf -X POST "$CART_URL/api/cart/items" \
  -H "X-User-Id: $DEMO_USER" -H "Content-Type: application/json" \
  -d '{"productId":"p1","name":"Laptop","unitPrice":1200,"quantity":1}' >/dev/null

log "Checkout"
curl -sf -X POST "$CART_URL/api/cart/checkout" -H "X-User-Id: $DEMO_USER" >/dev/null

log "Finding latest order for $DEMO_USER"
ORDER_ID=$(find_latest_order "$DEMO_USER")
[ -n "$ORDER_ID" ] || fail "no order found for user"

wait_status "$ORDER_ID" "AWAITING_PAYMENT"

log "Simulating successful payment via Kafka"
PAYLOAD="{\"orderId\":\"$ORDER_ID\",\"transactionId\":\"e2e-txn\",\"amount\":1200}"
docker exec "$KAFKA_SERVICE" kafka-console-producer \
  --bootstrap-server "$KAFKA_BOOTSTRAP" \
  --topic payment.succeeded \
  --property "parse.key=true" \
  --property "key.separator=:" <<< "$ORDER_ID:$PAYLOAD"

wait_status "$ORDER_ID" "CONFIRMED"

log "E2E PASSED — order $ORDER_ID confirmed through full saga."

log "=== Fraud-flag branch ==="

FRAUD_USER="e2e_fraud_user"
log "Seeding fraud-scenario user"
curl -sf -X POST "$USER_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$FRAUD_USER\",\"email\":\"e2e-fraud@example.com\",\"password\":\"$DEMO_PASSWORD\"}" >/dev/null 2>&1 \
  || true

log "Filling cart with a large order for fraud scenario"
curl -sf -X POST "$CART_URL/api/cart/items" \
  -H "X-User-Id: $FRAUD_USER" -H "Content-Type: application/json" \
  -d '{"productId":"p1","name":"Laptop","unitPrice":1200,"quantity":50}' >/dev/null

curl -sf -X POST "$CART_URL/api/cart/checkout" -H "X-User-Id: $FRAUD_USER" >/dev/null

log "Finding latest order for $FRAUD_USER"
FRAUD_ORDER_ID=$(find_latest_order "$FRAUD_USER")
[ -n "$FRAUD_ORDER_ID" ] || fail "no order found for fraud user"

wait_status "$FRAUD_ORDER_ID" "AWAITING_PAYMENT"

log "Simulating fraud flag via Kafka"
FRAUD_PAYLOAD="{\"orderId\":\"$FRAUD_ORDER_ID\",\"riskScore\":\"0.95\",\"reason\":\"e2e simulated fraud\"}"
docker exec "$KAFKA_SERVICE" kafka-console-producer \
  --bootstrap-server "$KAFKA_BOOTSTRAP" \
  --topic fraud.flagged \
  --property "parse.key=true" \
  --property "key.separator=:" <<< "$FRAUD_ORDER_ID:$FRAUD_PAYLOAD"

wait_status "$FRAUD_ORDER_ID" "CANCELLED"

log "E2E PASSED — fraud order $FRAUD_ORDER_ID cancelled with compensation."
