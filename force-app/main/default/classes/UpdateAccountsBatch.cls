public with sharing class UpdateAccountsBatch implements Database.Batchable<SObject>, Database.Stateful {

    public Integer recordsProcessed = 0;

    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        // Get accounts that have at least one activated order
        return Database.getQueryLocator('SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Order WHERE Status = \'Activated\')');
    }

    public void execute(Database.BatchableContext batchContext, List<Account> accounts) {

        List<AggregateResult> aggregateResults = OrderSelector.getSumOfTotalAmountOfActivatedOrdersGroupedByAccounts(accounts);
        List<Account> accountsToUpdate = new List<Account>();

        for (Account account : accounts) {
            for (AggregateResult aggregateResult : aggregateResults) {
                if (account.id == aggregateResult.get('AccountId')) {
                    account.AnnualRevenue = (decimal) aggregateResult.get('total');
                    accountsToUpdate.add(account);
                    recordsProcessed += 1;
                }
            }
        }
        
        update accountsToUpdate;
    }

    public void finish(Database.BatchableContext batchContext) {
        System.debug('Batch completed. ' + recordsProcessed + ' records processed.');
    }
}