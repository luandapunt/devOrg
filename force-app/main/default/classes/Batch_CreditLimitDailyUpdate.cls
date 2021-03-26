global class Batch_CreditLimitDailyUpdate implements Database.Batchable<SObject>, Database.AllowsCallouts{
    global Database.QueryLocator start(Database.BatchableContext bc){       
        return Database.getQueryLocator(
            'SELECT Id, CodeCustomerTxt__c FROM ACCOUNT WHERE CodeCustomerTxt__c <> null'
            //FILTRAR APENAS CONTAS JURIDICA SAP
            //FILTRAR APENAS CONTAS COM CÓDIGO SAP PREENCHIDO
        );
    }
    
    global void execute(Database.BatchableContext bc, List<Account> scope){                  
        List<Id> accIdList = new List<Id>();
         
        for(Account acc : scope){
       		accIdList.add(acc.Id);
        }
        
        CreditLimitIntegrationUtils.getCreditLimit(accIdList);
    }
    
    global void finish(Database.BatchableContext bc){
    	System.debug('Batch_CreditLimitDailyUpdate Finalizada');
    }
}