@isTest
private class Test_OpportunityTriggerHandler {
    
    @isTest static void testOpp(){
        RecordTypeMap rt = RecordTypeMap.getInstance();
 		String rtSACAcc = rt.rtmap.get('Account').get('BusinessAccountSAC');
        Account acc = TestData.createAccount('TestAccount', null, null, rtSACAcc);
        AccountAreaSales__c sa = TestData.createAccountAreaSales(acc.Id, null, null);
        Opportunity oppWithSA = TestData.createOpportunity('TestOpportunity', 'Qualificação', null, sa.Id);
        oppWithSA = [Select Id, AccountId
               From Opportunity
               Where Id =: oppWithSA.Id];
        Opportunity oppWithAcc = TestData.createOpportunity('TestOpp', 'Qualificação', acc.Id, null);
        oppWithAcc = [Select Id, Opty_Sales_Area__c
               From Opportunity
               Where Id =: oppWithAcc.Id];
        System.assertEquals(acc.Id, oppWithSA.AccountId);
        System.assertEquals(sa.Id, oppWithAcc.Opty_Sales_Area__c);
    }

}