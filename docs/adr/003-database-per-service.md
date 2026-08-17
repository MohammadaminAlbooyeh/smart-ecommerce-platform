# ADR-003: Database Per Service

## Status
Accepted

## Context
Chandin microservice-e mostaghel darim ke bayad be surat-e mostaghel deploy va scale beshan.

## Decision
Har microservice DB-e mostaghel-e khodesh ro dare (PostgreSQL baraye service-haye transactional, Redis baraye cart-service). Hich service-i mostaghim be database-e service-e digar dastresi nadare — faghat az tarigh-e API ya Kafka event.

## Consequences
- Consistency-e cross-service az tarigh-e eventual consistency + saga pattern ta'min mishe, na distributed transaction.
- Complexity-e operational bala mire (chandin DB instance baraye modiriat), vali service-ha kamelan mostaghel deploy mishan.
