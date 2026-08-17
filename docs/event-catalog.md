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

## Naming Convention

Topic-ha az format-e `<domain>.<event_past_tense>` peyravi mikonan (masalan `order.created`, na `create-order` ya `OrderCreated`).

Schema-haye rasmi-e in event-ha dar `shared/java-common-lib` (Java) va `shared/python-common-lib` (Python) tarif shodan.
