public with sharing class OpportunityTriggerHandler extends fflib_SObjectDomain implements ITestAble {
    
    public OpportunityTriggerHandler(List<Order__c> sObjectList){
        super((List<SObject>)sObjectList);
    }
    
    public override void onBeforeInsert(){
        this.setSalesAreaOrAccount((List<Opportunity>) records);
    }
    
    
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new OpportunityTriggerHandler(sObjectList);
        }
    }
    
    public static Opportunity getSampleObject() {
        return new Opportunity();
    }
    
    private void setSalesAreaOrAccount(List<Opportunity> records){
        List<Id> listIds = new List<Id>();
        List<Id> listAccIds = new List<Id>();
        List<Id> listAvIds = new List<Id>();
        Map<Id, List<AccountAreaSales__c>> mapSalesAreaByAccount = new Map<Id, List<AccountAreaSales__c>>();
        for(Opportunity o : records){
            if(o.Account == null || o.Opty_Sales_Area__c == null){
                listIds.add(o.Id);
                if(o.AccountId != null) listAccIds.add(o.AccountId);
                if(o.Opty_Sales_Area__c != null) listAvIds.add(o.Opty_Sales_Area__c);
            }
        }
        if(listIds.size() > 0){
            Map<Id, AccountAreaSales__c> mapAv = new Map<Id, AccountAreaSales__c>([
                SELECT Id, 
                AccountLkp__c, 
                CodeSalesOrganizationTxt__c, 
                SellerLkp__c, 
                SellerLkp__r.UserLkp__c,
                SellerLkp__r.SellerNumberNmb__c,
                SellerLkp__r.UserLkp__r.CPFTxt__c
                //OwnerId 
                FROM AccountAreaSales__c 
                WHERE AccountLkp__c IN :listAccIds 
                OR Id IN :listAvIds
            ]);
            for(AccountAreaSales__c av : mapAv.values()){
                List<AccountAreaSales__c> listAux = new List<AccountAreaSales__c>();
                if(mapSalesAreaByAccount.containsKey(av.AccountLkp__c)){
                    listAux = mapSalesAreaByAccount.get(av.AccountLkp__c);
                }
                listAux.add(av);
                mapSalesAreaByAccount.put(av.AccountLkp__c, listAux);
            }
            for(Opportunity o : records){
                if(o.AccountId == null && o.Opty_Sales_Area__c == null){
                    o.addError('A conta ou área de vendas devem estar selecionadas');
                }
                else if(o.AccountId == null){
                    o.AccountId = mapAv.get(o.Opty_Sales_Area__c).AccountLkp__c;
                    if(o.Opty_Sales_Area__r.SellerLkp__r.UserLkp__r.CPFTxt__c != null){
                    	o.SellerCPFTxt__c = mapAv.get(o.Opty_Sales_Area__c).SellerLkp__r.UserLkp__r.CPFTxt__c;
                    }
                }
                else if(o.Opty_Sales_Area__c == null){
                    if(mapSalesAreaByAccount.containsKey(o.AccountId)){
                        List<AccountAreaSales__c> listAux = mapSalesAreaByAccount.get(o.AccountId);
                        if(listAux.size() == 1){
                            o.Opty_Sales_Area__c = listAux[0].Id;
                            if(listAux[0].SellerLkp__r.UserLkp__r.CPFTxt__c != null){
                            	o.SellerCPFTxt__c = listAux[0].SellerLkp__r.UserLkp__r.CPFTxt__c;
                            }  
                        }
                        else{
                            o.addError('Existe mais de uma Área de Vendas possível para esse cliente, favor selecionar');
                        }
                    }	
                }
                
            }
        }
    }
}