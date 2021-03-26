@isTest
private class Test_CatalogElementTriggerHandler {
    
    @isTest static void testIndex(){
        Pricebook__c pb = TestData.createPricebook('TestPricebook');
        CatalogElement__c element1 = TestData.createCatalogElement('TestElement1', 1, pb.Id, null);
        CatalogElement__c element2 = TestData.createCatalogElement('TestElement2', 20, pb.Id, null);
        CatalogElement__c element3 = TestData.createCatalogElement('TestElement3', 3, pb.Id, null);
        CatalogElement__c elementMaster = TestData.createCatalogElement('TestElementMaster', null, null, null);
        CatalogElement__c element4 = TestData.createCatalogElement('TestElement4', 4, null, elementMaster.Id);
        CatalogElement__c element5 = TestData.createCatalogElement('TestElement5', 7, null, elementMaster.Id);
        CatalogElement__c element6 = TestData.createCatalogElement('TestElement6', 6, null, elementMaster.Id);
        
        Test.startTest();
        element2.IndexNmb__c = 2;
        update element2;
        element5.IndexNmb__c = 5;
        update element5;
        Test.stopTest();
        
        element2 = [Select Id, PreviousElementLkp__c, NextElementLkp__c, ParentElementLkp__c
                    From CatalogElement__c
                    Where Id =: element2.Id];
        system.debug(element2);
        element5 = [Select Id, PreviousElementLkp__c, NextElementLkp__c, ParentElementLkp__c
                    From CatalogElement__c
                    Where Id =: element5.Id];
        System.assertEquals(element1.Id, element2.PreviousElementLkp__c);
        System.assertEquals(element3.Id, element2.NextElementLkp__c);
     	System.assertEquals(element4.Id, element5.PreviousElementLkp__c);
        System.assertEquals(element6.Id, element5.NextElementLkp__c);
    }

}