global class BatchSetOrderAVOwner implements Database.Batchable<sObject>{
    public Decimal numMultipleAVs = 0;
    
	global Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator([SELECT Id, AccountLkp__c, CodeSalesOrganizationTxt__c FROM Order__c WHERE AccountAreaSalesLkp__c = null]);
    }

    global void execute(Database.BatchableContext BC, List<Order__c> scope) {
        List<Id> listAccIds = new List<Id>();
        Map<Id, Id> mapOrderAccount = new Map<Id, Id>();
        Map<Id, List<AccountAreaSales__c>> mapAccountAV = new Map<Id, List<AccountAreaSales__c>>();
        List<Order__c> listOrderToUpdate = new List<Order__c>();
        
        for(Order__c o : scope){
			listAccIds.add(o.AccountLkp__c);
		}
        
        for(Account a : [SELECT Id, 
                         (SELECT Id, SellerLkp__r.UserLkp__c, CodeSalesOrganizationTxt__c
                          FROM AreasDeVendas__r WHERE SellerLkp__r.Userlkp__c != null) 
                         FROM Account WHERE Id IN :listAccIds 
                         AND Id IN (SELECT AccountLkp__c FROM AccountAreaSales__c)])
        {
            
            mapAccountAV.put(a.Id, a.AreasDeVendas__r);
            
        }
    
        for(Order__c o : scope){
            if(mapAccountAv.containsKey(o.AccountLkp__c)){
                for(AccountAreaSales__c av : mapAccountAV.get(o.AccountLkp__c)){
                    if(av.CodeSalesOrganizationTxt__c == o.CodeSalesOrganizationTxt__c){
                        o.AccountAreaSalesLkp__c = av.Id;
                        o.OwnerId = av.SellerLkp__r.UserLkp__c;
                        listOrderToUpdate.add(o);
                        break;
                    }
                }
                
                
            }
        }
        
        SkipValidations__c skipVal = SkipValidations__c.getOrgDefaults();
        skipVal.Skip__c = true;
        update skipVal;
        
		update listOrderToUpdate;
        
        skipVal.Skip__c = false;
        update skipVal;

    }
    
    global void finish(Database.BatchableContext BC) {
        system.debug(numMultipleAVs);
    }
}