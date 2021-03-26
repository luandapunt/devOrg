global class BatchRenameAV implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator([SELECT Id,  Name FROM AccountAreaSales__c WHERE Name LIKE 'AVE%']);
    }

    global void execute(Database.BatchableContext BC, List<AccountAreaSales__c> scope) {
        
        
        for(AccountAreaSales__c av : scope){
			//av.Name = av.Name.replace('AVE', 'MEX'); 
		}
		update scope;

    }
    
    global void finish(Database.BatchableContext BC) {
     
    }
    
}