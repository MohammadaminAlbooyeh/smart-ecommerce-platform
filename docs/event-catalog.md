# Event Catalog

List-e kamel-e Kafka topic-ha va event-haee ke bein-e service-ha rad-o-badal mishan.

| Topic | Producer | Consumer(s) | Payload (khalase) |
|---|---|---|---|
| `order.created` | order-service | inventory-service, real_time_fraud_detection_system, real_time_analytics_dashboard | orderId, userId, items[], totalAmount |
| `inventory.reserved` | inventory-service | order-service | orderId, reservationId, items[] |
| `inventory.reservation_failed` | inventory-service | order-service | orderId, reason |
| `fraud.flagged` | real_time_fraud_detection_system | order-service | orderId, riskScore, reason |
| `order.awaiting_payment` | order-service | payment-switch-gateway | orderId, amount, userId |
| `payment.succeeded` | payment-switch-gateway | order-service, real_time_analytics_dashboard | orderId, transactionId, amount |
| `payment.failed` | payment-switch-gateway | order-service | orderId, transactionId, reason |
| `order.confirmed` | order-service | recommendation_engine, real_time_analytics_dashboard | orderId, userId, items[] |
| `order.cancelled` | order-service | real_time_analytics_dashboard | orderId, reason |
| `product.viewed` | product-search-engine | recommendation_engine | userId, productId, timestamp |
| `cart.checkout` | cart-service | order-service | orderId, userId, items[], totalAmount |
| `inventory.reservation_cancel` | order-service | inventory-service | orderId (saga compensation — releases stock) |

## Naming Convention

Topic-ha az format-e `<domain>.<event_past_tense>` peyravi mikonan (masalan `order.created`, na `create-order` ya `OrderCreated`).

Schema-haye rasmi-e in event-ha dar `shared/java-common-lib` (Java) va `shared/python-common-lib` (Python) tarif shodan.

## Saga Compensation

`inventory.reservation_cancel` topic-e compensation-e saga-e: vaghti order-service `fraud.flagged` ya `payment.failed` ro migire, order-ro `CANCELLED` mikone va in event-ro publish mikone ta inventory-service reservation-e marboote-ro cancel kone va stock-o release kone. Natije: `order.cancelled` publish mishe.

In flow-o [architecture.md](architecture.md#compensation-path-fraud--payment-failure) diagram karde, va `scripts/test-e2e.sh` (fraud-flag branch) end-to-end test-esh mikone — checkout -> `fraud.flagged` -> order `CANCELLED` -> reservation-e marboote `CANCELLED`.

## Testing Coverage

- **Pooshesh dare** (`scripts/test-e2e.sh`): `cart.checkout`, happy-path `payment.succeeded`, `fraud.flagged` + `inventory.reservation_cancel` compensation.
- **Pooshesh nadare hanuz**: `payment.failed` (be jaye fraud), `inventory.reservation_failed` (out-of-stock scenario), retry/timeout/idempotency-e consumer-ha.
