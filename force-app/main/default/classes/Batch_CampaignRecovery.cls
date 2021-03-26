global class Batch_CampaignRecovery implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(
        	'SELECT Id FROM Campaign__c WHERE Active__c = TRUE'
        );
    }
    
    global void execute(Database.BatchableContext bc, List<Campaign__c> scope){
        for(Campaign__c cmp : scope){
            CampaignUtility.campaignRecovery(cmp.Id);
            CampaignUtility.createCreditNote(cmp.Id, System.today());
        }
    }
 	   
    global void finish(Database.BatchableContext bc){
        /*Batch_GenerateCreditNote batchCreditNote = new Batch_GenerateCreditNote();
        Id batchId = Database.executeBatch(batchCreditNote, 200);*/ 
    }

}