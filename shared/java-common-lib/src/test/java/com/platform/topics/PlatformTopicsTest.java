package com.platform.topics;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class PlatformTopicsTest {

    @Test
    void allTopicConstantsAreNonEmpty() {
        assertTrue(PlatformTopics.CART_CHECKOUT.length() > 0);
        assertTrue(PlatformTopics.ORDER_CREATED.length() > 0);
        assertTrue(PlatformTopics.ORDER_AWAITING_PAYMENT.length() > 0);
        assertTrue(PlatformTopics.ORDER_CONFIRMED.length() > 0);
        assertTrue(PlatformTopics.ORDER_CANCELLED.length() > 0);
        assertTrue(PlatformTopics.INVENTORY_RESERVED.length() > 0);
        assertTrue(PlatformTopics.INVENTORY_RESERVATION_FAILED.length() > 0);
        assertTrue(PlatformTopics.INVENTORY_RESERVATION_CANCEL.length() > 0);
        assertTrue(PlatformTopics.FRAUD_FLAGGED.length() > 0);
        assertTrue(PlatformTopics.PAYMENT_SUCCEEDED.length() > 0);
        assertTrue(PlatformTopics.PAYMENT_FAILED.length() > 0);
        assertTrue(PlatformTopics.PRODUCT_VIEWED.length() > 0);
    }

    @Test
    void topicConstantsFollowNamingConvention() {
        String regex = "^[a-z]+\\.[a-z_]+$";
        assertTrue(PlatformTopics.ORDER_CREATED.matches(regex));
        assertTrue(PlatformTopics.INVENTORY_RESERVATION_CANCEL.matches(regex));
        assertTrue(PlatformTopics.CART_CHECKOUT.matches(regex));
    }
}
