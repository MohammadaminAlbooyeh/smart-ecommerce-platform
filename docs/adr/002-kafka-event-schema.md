# ADR-002: Kafka Event Schema

## Status
Accepted

## Context
Baraye inke service-haye Java va Python betunan bedun-e ambiguity ba ham event radobadal konan, niaz be yek gharardad-e moshakhas baraye schema-ye event-ha dar Kafka darim.

## Decision
- Har event shamel-e in field-haye common ast: `eventId`, `eventType`, `timestamp`, `payload`.
- Topic naming convention: `<domain>.<event_past_tense>` (masalan `order.created`).
- Schema-ha be surat-e explicit dar `shared/java-common-lib` (POJO/record) va `shared/python-common-lib` (Pydantic model) tarif mishan — na az tarigh-e schema registry (dar in marhale az project).
- Serialization: JSON (na Avro) baraye sadegi dar marhale-ye avval-e project.

## Consequences
- Har taghir dar schema niaz be hamzaman update kardan-e do shared lib dare.
- Dar ayande momken ast be Avro + Schema Registry migrate konim age need-e backward compatibility jeddi tar shod.
