public with sharing class OrderSelector {

    // i.e. the company's turnover

    public static AggregateResult getSumOfTotalAmountOfActivatedOrders() {
        AggregateResult aggregateResult = [SELECT SUM(TotalAmount) total FROM Order WHERE Status = 'Activated'];
        return aggregateResult;
    }

    public static List<AggregateResult> getSumOfTotalAmountOfActivatedOrdersGroupedByAccounts(List<Account> accounts) {
        return [SELECT SUM(TotalAmount) total, AccountId
                FROM Order
                WHERE AccountId IN: accounts AND Status = 'Activated'
                GROUP BY AccountId];
    }

    public static List<Order> getActivatedOrdersByAccountId(Set<Id> accountsIds) {
        return [SELECT Id, TotalAmount, AccountId, Status
                FROM Order
                WHERE AccountId IN :accountsIds AND Status = 'Activated'];
    }
    
}