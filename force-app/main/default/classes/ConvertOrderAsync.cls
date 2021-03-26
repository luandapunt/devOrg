public class ConvertOrderAsync implements Queueable, Database.AllowsCallouts{
    
    public final Id orderId;
    
    public void execute(QueueableContext context) {
        OrderIntegrationUtils.convertQuoteIntoOrder(orderId);
        
        Order__c ord = [SELECT Id, CustomIDTxt__c FROM Order__c WHERE Id = :orderId];
        
        Id jobID = System.enqueueJob(new UpdateOrderAsync(ord.CustomIDTxt__c));
    }
    
    public ConvertOrderAsync(Id orderId){
        this.orderId = orderId;
    }
}