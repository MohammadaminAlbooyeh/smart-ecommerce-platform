# Me'mari-e System

## Golden Path (Nemudar-e Kolli)

```
cart-service ──checkout──► order-service (Order created: PENDING)
                                │
                                ▼
                    Kafka: order.created
                                │
        ┌───────────────────────┼───────────────────────┐
        ▼                       ▼                       ▼
inventory-service      real_time_fraud_detection   real_time_analytics
(reserves stock)       (scores transaction risk)   (logs event)
        │                       │
        ▼                       ▼
Kafka: inventory.reserved   Kafka: fraud.flagged (if suspicious)
        │                       │
        └───────────┬───────────┘
                     ▼
              order-service (updates state via OrderStateMachine)
                     │
                     ▼
        Kafka: order.awaiting_payment
                     │
                     ▼
          payment-switch-gateway (charges via bank adapter)
                     │
                     ▼
        Kafka: payment.succeeded / payment.failed
                     │
                     ▼
              order-service (CONFIRMED or CANCELLED)
                     │
        ┌────────────┴────────────┐
        ▼                         ▼
recommendation_engine       real_time_analytics_dashboard
(updates purchase profile)  (updates sales metrics)
```

## Osool-e Tarahi

- **Database-per-service**: har microservice DB-e mostaghel-e khodesh ro dare (jozeiat: [ADR-003](adr/003-database-per-service.md))
- **Polyglot**: Java baraye service-haye core-e transactional (order, payment, inventory, cart, search, user); Python baraye ML/data-heavy service-ha (recommendation, fraud detection, analytics) — jozeiat: [ADR-001](adr/001-polyglot-language-split.md)
- **Event-driven via Kafka**: hameye cross-service communication az tarigh-e async events, na sync HTTP call. Jozeiat-e schema: [ADR-002](adr/002-kafka-event-schema.md)
- **Saga pattern baraye order lifecycle**: chon order-service ba chandin service digar (inventory, fraud, payment) dar tamas ast, be jaye distributed transaction az saga orchestration + compensation estefade mishe.

## Shared Libraries

- `shared/java-common-lib`: DTO-ha, Kafka event schema-ha, exception base class-ha baraye service-haye Java
- `shared/python-common-lib`: event schema-ha va Kafka util-ha baraye service-haye Python

Baraye list-e kamel-e event-ha be [event-catalog.md](event-catalog.md) negah konid.
