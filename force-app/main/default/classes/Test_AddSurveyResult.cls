@istest
public class Test_AddSurveyResult {

    @isTest static void testAll(){        
        
        Profile prof = [SELECT Id 
                        FROM Profile 
                        WHERE Name = 'Vendedor'];
        User u = TestData.createUser('TestSellerSurvey', null, null, prof.Id, 'sellerTestUser123@test.com');
        
        
        Profile profManager = [SELECT Id 
                               FROM Profile 
                               WHERE Name = 'Trade Marketing'];
        User uManager = TestData.createUser('TestManagerSurvey', null, null, profManager.Id, 'managerTestUser123@test.com');
        
        
        SalesOffice__c so = TestData.createSalesOffice('TestSalesOffice', uManager.Id);        
        Seller__c sel = TestData.createSeller('TestSeller', u.Id, so.Id);
        
        RecordTypeMap rt = RecordTypeMap.getInstance();
        String rtSAPAcc = rt.rtmap.get('Account').get('SAPBusinessAccount');
        Account acc = TestData.createAccount('TestAccount', null, null, rtSAPAcc);
        
        Channel__c channel = TestData.createChannel('VJ1', null);
        
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acc.Id, channel.Id, sel.Id);
        Product2 prod1 = TestData.createProduct('Test Product 1');
        
        TradeMktSurvey__c trdMktSurv = TestData.createTrdMktSurvey();       
        
        trdMktSurv = [SELECT Id, Name, BrandsTxt__c, LimitDate__c, IsActiveBln__c FROM TradeMktSurvey__c WHERE Id = :trdMktSurv.Id];
        salesArea = [SELECT Id, Name, SellerLkp__r.UserLkp__c FROM AccountAreaSales__c WHERE Id = :salesArea.Id];
        
        CustomerSurvey__c cstmSurv =  TestData.createCustomerSurvey(trdMktSurv, salesArea, 'Incompleta');
        SurveyProduct__c survProd1 = TestData.createSurveyProduct(trdMktSurv, prod1, null, null);
        SurveyProduct__c survProd2 = TestData.createSurveyProduct(trdMktSurv, null, 'Test Product 2', '01');
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(cstmSurv);
        AddSurveyResult controller = new AddSurveyResult(stdCon);
        	
        system.runAs(u){
            controller.doSave();
        }
    }
    
    
}