@isTest
public class Test_BatchSetAV {
    
    @isTest static void testOrder(){
        TestData.createSkipValidations();
        Order__c o = TestData.quickCreateOrder();
        o.CodeSalesOrganizationTxt__c = 'AM01';
        o.AccountAreaSalesLkp__c = null;
        update o;
        
        Test.startTest();
        Database.executeBatch(new BatchSetOrderAVOwner());
        Test.stopTest();
    }

    @isTest static void testCase(){
        TestData.createSkipValidations();
        Case c = TestData.quickCreateCase();
        c.AccountAreaSalesLkp__c = null;
        update c;
        
        Test.startTest();
        Database.executeBatch(new BatchSetCaseAV());
        Test.stopTest();
    }
    
}