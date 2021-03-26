global class Schedule_CleanIntegrationItem implements Schedulable{
    global void execute(SchedulableContext ctx) {
		Batch_CleanIntegrationItem batchIntegrationItem = new Batch_CleanIntegrationItem(); 
		Id batchId = Database.executeBatch(batchIntegrationItem, 1000);	
    }

}