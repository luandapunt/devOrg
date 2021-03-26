global class Schedule_AssociatePartner implements Schedulable{
    global void execute(SchedulableContext ctx){
		Batch_AssociatePartner batchAssociate = new Batch_AssociatePartner();
        Id batchId = Database.executeBatch(batchAssociate);
    }
}