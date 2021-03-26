global class Batch_AssociatePartner implements Database.Batchable<SObject>, Database.AllowsCallouts{
    global Database.QueryLocator start(Database.BatchableContext bc){       
        return Database.getQueryLocator(
            'SELECT CreatedDate, Id, CodeCustomerTxt__c, Parent.Id, Parent.CodeCustomerTxt__c, AssociatedToIssuerBln__c FROM ACCOUNT WHERE '+
            'CodeCustomerTxt__c <> null AND Parent.CodeCustomerTxt__c <> null AND AssociatedToIssuerBln__c = FALSE AND '+
            'RecordType.DeveloperName = \'AccountPartner\''
        );
    }
    
    global void execute(Database.BatchableContext bc, List<Account> scope){                  
        List<Id> accIdList = new List<Id>();
		
        System.debug('SCOPE');        
        System.debug(scope);
        
        for(Account acc : scope){
       		accIdList.add(acc.Id);
        }
        
        AccountIntegrationUtils.associatePartner(accIdList);
    }
    
    global void finish(Database.BatchableContext bc){
    	System.debug('Batch_AssociatePartner Finalizada');
    }
}