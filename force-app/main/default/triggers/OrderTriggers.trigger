trigger OrderTriggers on Order (after update) {

    OrderService.updateAccountAnnualRevenue(Trigger.new);

}