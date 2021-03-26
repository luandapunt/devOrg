global class Schedule_CampaignCalculation implements Schedulable{
    global void execute(SchedulableContext ctx) {
		Batch_CampaignCalculation batchCalculation = new Batch_CampaignCalculation(); 
		Id batchId = Database.executeBatch(batchCalculation, 1);	
    }
}