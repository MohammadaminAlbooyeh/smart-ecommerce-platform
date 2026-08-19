package com.platform.events;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import java.math.BigDecimal;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;

class OrderCreatedEventTest {

    private final ObjectMapper mapper = new ObjectMapper();

    @Test
    void builderCreatesValidInstance() {
        OrderCreatedEvent event = OrderCreatedEvent.builder()
                .orderId("ord-1")
                .userId("usr-1")
                .totalAmount(new BigDecimal("99.99"))
                .items(List.of(
                        OrderCreatedEvent.Item.builder()
                                .productId("prod-1")
                                .name("Test Product")
                                .unitPrice(new BigDecimal("49.99"))
                                .quantity(2)
                                .build()
                ))
                .build();

        assertEquals("ord-1", event.getOrderId());
        assertEquals("usr-1", event.getUserId());
        assertEquals(1, event.getItems().size());
    }

    @Test
    void serializesToJson() throws Exception {
        OrderCreatedEvent event = OrderCreatedEvent.builder()
                .orderId("ord-1")
                .userId("usr-1")
                .totalAmount(new BigDecimal("99.99"))
                .items(List.of())
                .build();

        String json = mapper.writeValueAsString(event);
        assertTrue(json.contains("ord-1"));
        assertTrue(json.contains("usr-1"));
    }

    @Test
    void deserializesFromJson() throws Exception {
        String json = "{\"orderId\":\"ord-1\",\"userId\":\"usr-1\",\"items\":[],\"totalAmount\":99.99}";
        OrderCreatedEvent event = mapper.readValue(json, OrderCreatedEvent.class);
        assertEquals("ord-1", event.getOrderId());
        assertEquals("usr-1", event.getUserId());
    }
}
