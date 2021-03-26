public class SummarizedRenevueTriggerHandler {
    public static void doBeforeInsert(List<SummarizedRevenue__c> records, Map<Id, SummarizedRevenue__c> oldRecords){

    }
    public static void doBeforeUpdate(List<SummarizedRevenue__c> records, Map<Id, SummarizedRevenue__c> oldRecords){

    }
    public static void doBeforeDelete(List<SummarizedRevenue__c> records, Map<Id, SummarizedRevenue__c> oldRecords){
        
    }
    public static void doAfterInsert(List<SummarizedRevenue__c> records, Map<Id, SummarizedRevenue__c> oldRecords){
        //AccountSharingUtil.processSalesAreaInsert(records, oldRecords);
        
    }
    public static void doAfterUpdate(List<SummarizedRevenue__c> records, Map<Id, SummarizedRevenue__c> oldRecords){
        //AccountSharingUtil.processSalesAreaUpdate(records, oldRecords);

    }
    public static void doAfterDelete(List<SummarizedRevenue__c> records, Map<Id, SummarizedRevenue__c> oldRecords){
        //AccountSharingUtil.processSalesAreaDelete(records, oldRecords);
    }
}