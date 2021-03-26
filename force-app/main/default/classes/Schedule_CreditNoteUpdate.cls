public class Schedule_CreditNoteUpdate implements Schedulable{
    public void execute(SchedulableContext ctx){
		Batch_CreditNoteUpdate batchCreditNote = new Batch_CreditNoteUpdate();
        Id batchId = Database.executeBatch(batchCreditNote);   
    } 
}