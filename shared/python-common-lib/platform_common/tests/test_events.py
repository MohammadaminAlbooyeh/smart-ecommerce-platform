import pytest

from platform_common.events import (
    OrderCreatedEvent,
    CartCheckoutEvent,
    InventoryReservedEvent,
    FraudFlaggedEvent,
)


class TestEvents:
    def test_order_created_roundtrip(self):
        event = OrderCreatedEvent(
            orderId="ord-1",
            userId="usr-1",
            items=[],
            totalAmount=99.99,
        )
        json_str = event.model_dump_json()
        parsed = OrderCreatedEvent.model_validate_json(json_str)
        assert parsed.orderId == "ord-1"
        assert parsed.userId == "usr-1"

    def test_cart_checkout_has_required_fields(self):
        event = CartCheckoutEvent(
            orderId="ord-1",
            userId="usr-1",
            items=[],
            totalAmount=49.99,
        )
        assert event.orderId == "ord-1"
        assert event.totalAmount == 49.99

    def test_fraud_flagged_default_score(self):
        event = FraudFlaggedEvent(
            orderId="ord-1",
            riskScore=0.9,
            reason="suspicious_ip",
        )
        assert event.riskScore == 0.9
        assert event.reason == "suspicious_ip"
