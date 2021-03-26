global class BatchSetCaseAV implements Database.Batchable<sObject>{
    public Decimal numMultipleAVs = 0;
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([SELECT Id, AccountId FROM Case WHERE AccountAreaSalesLkp__c = null]);
        //return Database.getQueryLocator([SELECT Id, AccountLkp__c, CodeSalesOrganizationTxt__c FROM Order__c WHERE AccountAreaSalesLkp__c = null]);
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
        List<Id> listAccIds = new List<Id>();
        Map<Id, Id> mapCaseAccount = new Map<Id, Id>();
        Map<Id, List<AccountAreaSales__c>> mapAccountAV = new Map<Id, List<AccountAreaSales__c>>();
        List<Case> listCaseToUpdate = new List<Case>();

        for(Case c : scope){
			listAccIds.add(c.AccountId); 
		}
        
        for(Account a : [SELECT Id, 
                         (SELECT Id, SellerLkp__r.UserLkp__c, CodeSalesOrganizationTxt__c
                          FROM AreasDeVendas__r) 
                         FROM Account WHERE Id IN :listAccIds 
                         AND Id IN (SELECT AccountLkp__c FROM AccountAreaSales__c)])
        {
            mapAccountAV.put(a.Id, a.AreasDeVendas__r); 
        }
    
        for(Case c : scope){
            if(mapAccountAv.containsKey(c.AccountId)){
                List<AccountAreaSales__c> listAV =  mapAccountAV.get(c.AccountId);
                if(listAV.size() == 1){
                    c.AccountAreaSalesLkp__c = listAV[0].Id;
                    listCaseToUpdate.add(c);
                }else{
                    for(AccountAreaSales__c av : mapAccountAV.get(c.AccountId)){
                        if(av.CodeSalesOrganizationTxt__c == 'AM01'){
                            c.AccountAreaSalesLkp__c = av.Id;
                            listCaseToUpdate.add(c);
                            break;
                        }
                    }                    
                }
            }
        }
        
        SkipValidations__c skipVal = SkipValidations__c.getOrgDefaults();
        skipVal.Skip__c = true;
        update skipVal;
        
		//update listCaseToUpdate;
        Database.update(listCaseToUpdate, false);

        skipVal.Skip__c = false;
        update skipVal; 
    }
    
    global void finish(Database.BatchableContext BC) {
        system.debug(numMultipleAVs);
    }
}