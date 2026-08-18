package com.platform.events;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderConfirmedEvent {

    private String orderId;
    private String userId;
    private List<OrderCreatedEvent.Item> items;
}
