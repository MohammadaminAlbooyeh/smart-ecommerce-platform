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

## Compensation Path (Fraud / Payment Failure)

Age `fraud.flagged` ya `payment.failed` beresad, order-service saga-ro rollback mikone:

```
fraud.flagged / payment.failed
              │
              ▼
   order-service (state -> CANCELLED)
              │
              ▼
   Kafka: inventory.reservation_cancel
              │
              ▼
   inventory-service (reservation -> CANCELLED, stock release mishe)
              │
              ▼
   Kafka: order.cancelled
              │
              ▼
   real_time_analytics_dashboard (metric update)
```

In compensation path-o `scripts/test-e2e.sh` pooshesh mide (fraud-flag branch + reservation release check).

## Shared Libraries

- `shared/java-common-lib`: DTO-ha, Kafka event schema-ha, exception base class-ha baraye service-haye Java
- `shared/python-common-lib`: event schema-ha va Kafka util-ha baraye service-haye Python

Baraye list-e kamel-e event-ha be [event-catalog.md](event-catalog.md) negah konid.

## Deployment

- **Local dev**: `infrastructure/docker-compose/docker-compose.full.yml` (postgres, redis, zookeeper, kafka, elasticsearch + hame-ye application service-ha, build-shode az sibling repo-haye local).
- **Kubernetes**: `infrastructure/k8s/base` (namespace, postgres, redis, kafka/zookeeper, elasticsearch, secrets) + `infrastructure/k8s/services` (per-service Deployment/Service manifest-ha — fe'lan faghat `user-service` complete-e, baghiye service-ha bayad be hamin format ezafe beshan).

## Known Gaps (in-progress)

- **Observability**: hich Prometheus/Grafana/OpenTelemetry/Jaeger setup-i hanuz nist. Baraye production bayad ezafe beshe.
- **Auth/security**: `user-service` faghat JWT sade dare; hich API gateway, rate limiting, ya mTLS bein-e service-ha nist.
- **CI**: pipeline-e fe'li (`.github/workflows/ci.yml`) faghat shared lib-ha, docker-compose config, va shell script-ha ro test/lint mikone — chon service repo-haye application in-repo nistan, CI nemitune saga-ro end-to-end run kone. `test-e2e.sh` bayad local (ba hame-ye sibling repo-ha checked out) run beshe.
