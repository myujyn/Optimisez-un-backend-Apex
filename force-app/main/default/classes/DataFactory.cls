public with sharing class DataFactory {

    public static Account createAccount(String accountName) {
        return new Account(Name = accountName);
    }

    public static Product2 createProduct(String productName) {
        return new Product2(Name = productName, IsActive = true);
    }

    public static PricebookEntry createPriceBookEntry (String product2Id, Double unitPrice) {
        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product2Id,
            UnitPrice = unitPrice,
            IsActive = true
        );
        return pricebookEntry;
    }

    // Create one order only

    public static Order createOrder(string accountId) {
        Order order = new Order(
            AccountId = accountId,
            Pricebook2Id = Test.getStandardPricebookId(),
            Status = 'Draft',
            EffectiveDate = Date.today()+30
        );
        return order;
    }

    // Create multiple orders once

    public static List<Order> createOrders (String accountId, Integer numberOfOrders) {
        
        List<Order> ordersList = new List<Order>();

        for (Integer i=0; i < numberOfOrders; i++) {
            Order order = new Order(
                AccountId = accountId,
                Pricebook2Id = Test.getStandardPricebookId(),
                Status = 'Draft',
                EffectiveDate = Date.today()+30
            );
            ordersList.add(order);
        }
        
        return ordersList;
    }

    // An Order Item needs a Product and a PricebookEntry to display data correctly, thus the Map parameter

    public static List<OrderItem> createOrderItems (List<Order> ordersList, Map<String,String> orderData, Decimal unitPrice) {
        
        List<OrderItem> orderItems = new List<OrderItem>();

        for (Order order : ordersList) {
            OrderItem orderItem = new OrderItem(
                OrderId = order.Id,
                Product2Id = orderData.get('Product2Id'),
                PricebookEntryId = orderData.get('PricebookEntryId'),
                Quantity = 10, // 1 order always has 10 order items
                UnitPrice = unitPrice
            );
            orderItems.add(orderItem);
        }
        return orderItems;
    }
}