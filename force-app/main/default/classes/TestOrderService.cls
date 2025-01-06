@isTest
public with sharing class TestOrderService {

    @TestSetup
    static void makeData(){
        // Création d'un compte
        Account account = DataFactory.createAccount('testAccount');
        insert account;

        // Création d'un produit
        Product2 product = DataFactory.createProduct('testProduct');
        insert product;

        // Création d'une entrée de catalogue de prix (PricebookEntry)
        PricebookEntry pricebookEntry = DataFactory.createPriceBookEntry(product.Id, 100);
        insert pricebookEntry;

        // Récupération du prix unitaire
        Decimal unitPrice = pricebookEntry.UnitPrice;

        // Créer plus de 100 commandes (par exemple, 150)
        List<Order> ordersList = DataFactory.createOrders(account.Id, 150);
        insert ordersList;

        // Création des articles de commande pour chaque commande
        Map<String,String> productWithPricebookEntry = new Map<String,String> {
            'Product2Id' => product.Id,
            'PricebookEntryId' => pricebookEntry.Id
        };
        
        List<OrderItem> orderItemsList = DataFactory.createOrderItems(ordersList, productWithPricebookEntry, unitPrice);
        insert orderItemsList;
    }

    @isTest
    public static void calculateNetAmountTest() {
        Order testOrder = [SELECT Id, ShipmentCost__c, NetAmount__c, TotalAmount FROM ORDER LIMIT 1];

        Test.startTest();
        System.assertEquals(0, testOrder.ShipmentCost__c, 'Shipment cost should be 0 initially');
        testOrder.ShipmentCost__c = 100;
        update testOrder;

        Test.stopTest();

        Decimal expectedResult = 900; // 10 products * 100 (unit price) - 100 (shipment cost)
        Decimal actualResult = [SELECT NetAmount__c FROM Order WHERE Id = :testOrder.Id].NetAmount__c;
        System.assertEquals(expectedResult, actualResult, 'Net Amount mismatch. Expected: ' + expectedResult + ', Actual: ' + actualResult);
    }

    @isTest
    public static void updateAccountAnnualRevenueTest() {
        // Activation de la première commande
        Order testOrder = [SELECT Id, Status FROM Order WHERE Status = 'Draft' LIMIT 1];
        
        Test.startTest();
        testOrder.Status = 'Activated';
        update testOrder;
        Test.stopTest();

        // Après activation, le revenu annuel du compte devrait être mis à jour
        Decimal expectedResult = 1000; // 10 produits * 100 (prix unitaire). Le revenu annuel n'inclut pas les frais d'expédition
        Decimal actualResult = [SELECT Id, AnnualRevenue FROM Account WHERE Name = 'testAccount'].AnnualRevenue;
        System.assertEquals(expectedResult, actualResult, 'Annual Revenue mismatch. Expected: ' + expectedResult + ', Actual: ' + actualResult);
    }

    @isTest
    public static void testLargeNumberOfOrders() {
        // Crée un grand nombre de commandes (150) et vérifie l'impact sur le revenu annuel
        Account account = [SELECT Id FROM Account WHERE Name = 'testAccount' LIMIT 1];
        List<Order> ordersList = [SELECT Id, Status, TotalAmount FROM Order WHERE AccountId = :account.Id];

        // Assurez-vous que nous avons bien 150 commandes
        System.assertEquals(150, ordersList.size(), 'Number of orders mismatch. Expected 150, Found: ' + ordersList.size());

        // Activation de toutes les commandes
        for (Order order : ordersList) {
            order.Status = 'Activated';
        }

        Test.startTest();
        update ordersList; // Activer toutes les commandes
        Test.stopTest();

        // Vérifier que le revenu annuel du compte a été mis à jour en fonction de toutes les commandes activées
        Decimal totalAmount = 150 * 1000; // 150 commandes, chaque ayant 10 articles à 100€ -> 10 * 100 = 1000
        Account updatedAccount = [SELECT AnnualRevenue FROM Account WHERE Id = :account.Id];
        System.assertEquals(totalAmount, updatedAccount.AnnualRevenue, 'The annual revenue does not match the expected value. Expected: ' + totalAmount + ', Found: ' + updatedAccount.AnnualRevenue);
    }
}
