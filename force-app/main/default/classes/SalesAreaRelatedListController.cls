public with sharing class SalesAreaRelatedListController {
    public List<AccountAreaSales__c> salesAreas {get;set;}

    public SalesAreaRelatedListController (ApexPages.StandardController stdController){
        stdController.addFields(new List<String> {'CodeCustomerTxt__c'});
        Account acc = (Account) stdController.getRecord();
        
        String accCode = acc.CodeCustomerTxt__c + '%';
        salesAreas = [SELECT Id, Name, CodeSalesOrganizationTxt__c, CodeDistribubutionChannelTxt__c, CodeActivitySectorTxt__c, SellerLkp__r.Name FROM AccountAreaSales__c WHERE CustomIdTxt__c LIKE :accCode];
        
        
    }
    
}