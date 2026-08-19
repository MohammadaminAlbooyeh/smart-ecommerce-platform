import pytest

from platform_common.topics import (
    CART_CHECKOUT,
    ORDER_CREATED,
    ORDER_AWAITING_PAYMENT,
    ORDER_CONFIRMED,
    ORDER_CANCELLED,
    INVENTORY_RESERVED,
    INVENTORY_RESERVATION_FAILED,
    INVENTORY_RESERVATION_CANCEL,
    FRAUD_FLAGGED,
    PAYMENT_SUCCEEDED,
    PAYMENT_FAILED,
    PRODUCT_VIEWED,
)


class TestTopics:
    def test_all_topics_non_empty(self):
        topics = [
            CART_CHECKOUT,
            ORDER_CREATED,
            ORDER_AWAITING_PAYMENT,
            ORDER_CONFIRMED,
            ORDER_CANCELLED,
            INVENTORY_RESERVED,
            INVENTORY_RESERVATION_FAILED,
            INVENTORY_RESERVATION_CANCEL,
            FRAUD_FLAGGED,
            PAYMENT_SUCCEEDED,
            PAYMENT_FAILED,
            PRODUCT_VIEWED,
        ]
        for topic in topics:
            assert len(topic) > 0, f"Topic constant is empty"

    def test_naming_convention(self):
        import re
        pattern = re.compile(r"^[a-z]+\.[a-z_]+$")
        assert pattern.match(ORDER_CREATED)
        assert pattern.match(INVENTORY_RESERVATION_CANCEL)
        assert pattern.match(CART_CHECKOUT)
