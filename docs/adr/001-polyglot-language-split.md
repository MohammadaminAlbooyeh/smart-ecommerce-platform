# ADR-001: Polyglot Language Split

## Status
Accepted

## Context
Platform shamel-e do daste service-e motefavet ast: service-haye core-e transactional (order, payment, inventory, cart, user, search) va service-haye ML/data-heavy (recommendation, fraud detection, analytics).

## Decision
- **Java (Spring Boot)** baraye service-haye transactional: `order-service`, `payment-switch-gateway`, `inventory-service`, `cart-service`, `user-service`, `product-search-engine`. In service-ha niaz be strong typing, mature transaction management, va performance-e bala baraye high-throughput request-e sync daran.
- **Python (FastAPI)** baraye service-haye ML/data: `recommendation_engine`, `real_time_fraud_detection_system`, `real_time_analytics_dashboard`. In service-ha az ecosystem-e ghani-e Python baraye ML (scikit-learn, PyTorch, pandas) estefade mikonan.

## Consequences
- Do shared library jodagane (`java-common-lib`, `python-common-lib`) baraye jelogiri az duplicate-e event schema-ha lazem shod.
- Team-ha bayad ba do stack ashna bashan, vali in trade-off dar barabar-e estefade behine az har zaban baraye kar-e monaseb ghabel-e ghabul ast.
