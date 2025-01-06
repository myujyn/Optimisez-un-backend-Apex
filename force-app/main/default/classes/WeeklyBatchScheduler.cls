global class WeeklyBatchScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        
        UpdateAccountsBatch batch = new UpdateAccountsBatch();
        Database.executeBatch(batch);
    }
}