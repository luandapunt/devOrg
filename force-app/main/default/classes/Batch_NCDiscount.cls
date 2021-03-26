global class Batch_NCDiscount implements Database.Batchable<sObject>, Database.AllowsCallouts{
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(
        	'SELECT ID, Name, (SELECT Id, Name FROM CampaignMechanics__r WHERE ApplyDiscountBln__c = TRUE OR ApplyDiscountBenefitBln__c = TRUE) FROM Campaign__c WHERE Active__c = TRUE'
        );   
    }
    global void execute(Database.BatchableContext bc, List<Campaign__c> scope){
        //List<Campaign__c> campaigns = new List<Campaign__c>();
        for (Campaign__c cmp : scope){
            if(cmp.CampaignMechanics__r.size() > 0){
                //System.debug('Campanha: '+cmp.Name+' possui '+cmp.CampaignMechanics__r.size()+' mecânicas que precisam de cálculo do desconto de NC');
            	CampaignUtility.getNCDiscount(cmp.Id, System.today());    
            }
        }
    }
    global void finish(Database.BatchableContext bc){       
        Batch_CampaignRecovery batchCampaignRecovery = new Batch_CampaignRecovery(); 
		Id batchId = Database.executeBatch(batchCampaignRecovery, 1); 
    }
}