global class ScheduledBatchCleanLogInterface implements Schedulable{
	global void execute(SchedulableContext sc) {
        LogInterfaceExpurgo__c logInt = LogInterfaceExpurgo__c.getInstance();
        Integer logIntDays = (logInt.Days__c).intvalue();
        Id batchInstanceId = Database.executeBatch(new BatchCleanLogInterface(logIntDays),200); 
    }
}