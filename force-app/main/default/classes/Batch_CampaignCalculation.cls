global class Batch_CampaignCalculation implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(
        	'SELECT ID FROM Campaign__c WHERE Active__c = TRUE'
        );   
    }
    global void execute(Database.BatchableContext bc, List<Campaign__c> scope){
        //List<Campaign__c> campaigns = new List<Campaign__c>();
        for (Campaign__c cmp : scope){
            System.debug('Campanha: '+cmp.Id);
        	CampaignUtility.computeRealized(cmp.Id, System.today());  
        }
    }
    global void finish(Database.BatchableContext bc){       
        Batch_NCDiscount batchNCDiscount = new Batch_NCDiscount(); 
		Id batchId = Database.executeBatch(batchNCDiscount, 1);
    }
}