# Smart E-Commerce Platform

Meta-repo baraye orchestration va document-e microservice-haye platform-e e-commerce. In repo khodesh code-e application nadare — faghat docs, docker-compose, shared lib-ha, va link be service repo-haye mostaghel ro negah midare.

## Me'mari

Platform az chandin microservice-e mostaghel tashkil shode ke az tarigh-e Kafka events ba ham harf mizanan (event-driven architecture). Har service repo-ye jodagane khodesh ro dare.

Baraye jozeiat-e kamel-e me'mari be [`docs/architecture.md`](docs/architecture.md) negah konid.

## Service Repos

| Service | Zaban | Vaziat | Tozih |
|---|---|---|---|
| [`payment-switch-gateway`](../payment-switch-gateway) | Java | Mojood | Payment gateway adapter (SEP, Behpardakht, ...) |
| [`order-service`](../order-service) *(ex: taskflow-api)* | Java | Mojood — dar hal-e tose'e | Saga orchestration, order lifecycle |
| [`inventory-service`](../inventory-service) | Java | Jadid | Modiriat-e stock va reservation |
| [`cart-service`](../cart-service) | Java | Jadid | Sabad-e kharid (Redis-backed) |
| [`product-search-engine`](../product-search-engine) | Java | Mojood | Search, price comparison, ranking |
| [`recommendation_engine`](../recommendation_engine) | Python | Mojood — dar hal-e tose'e | Personalized recommendations |
| [`real_time_fraud_detection_system`](../real_time_fraud_detection_system) | Python | Mojood — dar hal-e tose'e | Real-time fraud scoring |
| [`real_time_analytics_dashboard`](../real_time_analytics_dashboard) | Python | Mojood — dar hal-e tose'e | Sales & business analytics |
| [`user-service`](../user-service) | Java | Jadid | Auth va user management |

## Shorou'-e Sari' (Local Dev)

```bash
./scripts/setup-local-env.sh   # clone + build + run hame-ye service-ha
./scripts/seed-demo-data.sh    # demo data seed konid
```

Ya mostaghim ba docker-compose:

```bash
docker compose -f infrastructure/docker-compose/docker-compose.full.yml up
```

## Docs

- [architecture.md](docs/architecture.md) — tarah-e koli-e system va diagram-ha
- [adr/](docs/adr) — Architecture Decision Records
- [event-catalog.md](docs/event-catalog.md) — list-e kamel-e Kafka topic-ha va event-ha
- [api-specs/](docs/api-specs) — OpenAPI spec-e har service
