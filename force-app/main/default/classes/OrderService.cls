public with sharing class OrderService {

    public static void updateAccountAnnualRevenue(List<Order> orders) {
        
        Set<Id> accountsIds = new Set<Id>();

        for (Order order : orders) {
            accountsIds.add(order.AccountId);
        }

        List<Account> accounts = AccountSelector.getAccountsWithAnnualRevenue(accountsIds);
        List<Order> activatedOrders = OrderSelector.getActivatedOrdersByAccountId(accountsIds);

        // For each account, the order amount of the activated orders is added to the current annual revenue

        for (Account account: accounts) {
            account.AnnualRevenue = 0;
            for (integer i=0; i < activatedOrders.size(); i++) {
                if (activatedOrders[i].AccountId == account.Id) {
                    account.AnnualRevenue += activatedOrders[i].TotalAmount;
                }
            }
        }

        update accounts;
    }
}