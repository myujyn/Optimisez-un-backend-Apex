@isTest
public with sharing class TestUpdateAccountsBatch {

    @TestSetup
    static void makeData(){

        List<Account> accountsList = new List<Account>();
        for (Integer i=0; i < 10; i++) {
            Account account = DataFactory.createAccount('testAccount' + i);
            accountsList.add(account);
        }
        insert accountsList;

        Product2 product = DataFactory.createProduct('testProduct');
        insert product;

        PricebookEntry pricebookEntry = DataFactory.createPriceBookEntry(product.Id, 100);
        insert pricebookEntry;

        Decimal unitPrice = pricebookEntry.UnitPrice;

        // 101 orders are created to confirm that if an account has more than 100 orders, it still can be updated

        List<Order> ordersList = new List<Order>();
        for (Account account : accountsList) {
            for (Integer i=0; i < 101; i++) {
                ordersList.add(DataFactory.createOrder(account.Id));
            }
        }
        insert ordersList;

        Map<String,String> productWithPricebookEntry = new Map<String,String> {
            'Product2Id' => product.Id,
            'PricebookEntryId' => pricebookEntry.Id
        };
        List<OrderItem> orderItemsList = DataFactory.createOrderItems(ordersList, productWithPricebookEntry, unitPrice);
        insert orderItemsList;
        
    }

    @isTest
    public static void updateAccountsBatchTest() {

        List<Order> ordersList = [SELECT Id, Status FROM Order LIMIT 1100];
        for ( Order order : ordersList) {
            order.Status = 'Activated';
        }
        update ordersList;

        Test.startTest();
        UpdateAccountsBatch updateAccountsBatch = new UpdateAccountsBatch();
        Id bacthId = Database.executeBatch(updateAccountsBatch);
        Test.stopTest();

        // After the batch is executed, the annual revenue for each of the 10 accounts must equals the sum of total amount of all activated orders

        Decimal expectedResult = 101000; // 101 orders * 10 products * 100 (unit price)
        List<Account> accountsList = [SELECT Id, Name, AnnualRevenue FROM Account WHERE Name LIKE '%testAccount%'];
        for (Account account : accountsList) {
            System.assertEquals(expectedResult, account.AnnualRevenue, 'Annual Revenue is '+ account.AnnualRevenue+ '. Expected was ' + expectedResult +' on ' + account);
        }

    }
}