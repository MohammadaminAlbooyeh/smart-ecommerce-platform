package com.platform.topics;

public final class PlatformTopics {

    private PlatformTopics() {
    }

    public static final String CART_CHECKOUT = "cart.checkout";
    public static final String ORDER_CREATED = "order.created";
    public static final String ORDER_AWAITING_PAYMENT = "order.awaiting_payment";
    public static final String ORDER_CONFIRMED = "order.confirmed";
    public static final String ORDER_CANCELLED = "order.cancelled";
    public static final String INVENTORY_RESERVED = "inventory.reserved";
    public static final String INVENTORY_RESERVATION_FAILED = "inventory.reservation_failed";
    public static final String INVENTORY_RESERVATION_CANCEL = "inventory.reservation_cancel";
    public static final String FRAUD_FLAGGED = "fraud.flagged";
    public static final String PAYMENT_SUCCEEDED = "payment.succeeded";
    public static final String PAYMENT_FAILED = "payment.failed";
    public static final String PRODUCT_VIEWED = "product.viewed";
}
