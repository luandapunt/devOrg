global class Schedule_CleanInvoice implements Schedulable{
    global void execute(SchedulableContext ctx) {
		Batch_CleanInvoice batchInvoice = new Batch_CleanInvoice(); 
		Id batchId = Database.executeBatch(batchInvoice, 1000);	
    }

}