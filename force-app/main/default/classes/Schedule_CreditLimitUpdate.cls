global class Schedule_CreditLimitUpdate implements Schedulable{
    global void execute(SchedulableContext ctx){
		Batch_CreditLimitDailyUpdate batchCreditLimit = new Batch_CreditLimitDailyUpdate();
        Id batchId = Database.executeBatch(batchCreditLimit);   
    }
}