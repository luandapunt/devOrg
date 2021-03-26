global class Schedule_QuotaUpdate implements Schedulable{
    global void execute(SchedulableContext ctx) {
		Batch_QuotaDailyUpdate batchQuota = new Batch_QuotaDailyUpdate(); 
		Id batchId = Database.executeBatch(batchQuota);	
    }
}