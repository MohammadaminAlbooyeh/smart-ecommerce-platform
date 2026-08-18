"""Canonical Pydantic event schemas shared by the Python services."""

from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel


class OrderItem(BaseModel):
    product_id: str
    name: Optional[str] = None
    unit_price: float
    quantity: int


class CartCheckoutEvent(BaseModel):
    order_id: str
    user_id: str
    items: List[OrderItem]
    total_amount: Optional[float] = None


class OrderCreatedEvent(BaseModel):
    order_id: str
    user_id: str
    items: List[OrderItem]
    total_amount: float


class InventoryReservedEvent(BaseModel):
    order_id: str
    reservations: List[dict]


class InventoryReservationFailedEvent(BaseModel):
    order_id: str
    reason: str


class InventoryReservationCancelEvent(BaseModel):
    order_id: str


class FraudFlaggedEvent(BaseModel):
    order_id: str
    risk_score: str
    reason: str


class OrderAwaitingPaymentEvent(BaseModel):
    order_id: str
    amount: float
    user_id: str


class PaymentSucceededEvent(BaseModel):
    order_id: str
    transaction_id: str
    amount: float


class PaymentFailedEvent(BaseModel):
    order_id: str
    transaction_id: str
    reason: str


class OrderConfirmedEvent(BaseModel):
    order_id: str
    user_id: str
    items: List[OrderItem]


class OrderCancelledEvent(BaseModel):
    order_id: str
    reason: str


class ProductViewedEvent(BaseModel):
    user_id: str
    product_id: str
    timestamp: datetime
