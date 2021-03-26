@isTest
public class Test_QuotaIntegrationUtils {
    @isTest static void testQuotaBatch(){
        TestData.createIntegrationData();
        RecordTypeMap rt = RecordTypeMap.getInstance();
 		String rtSAPAcc = rt.rtmap.get('Account').get('SAPBusinessAccount');
        Profile prof = [SELECT Id 
                        FROM Profile 
                        WHERE Name = 'Gerente de Vendas'];
        User salesOfficeManager = TestData.createUser('TestManager', null, null, prof.Id, 'testUser321@test.com');
        SalesOffice__c so = TestData.createSalesOffice('TestSalesOffice', salesOfficeManager.Id);
        Seller__c sel = TestData.createSeller('TestSeller', salesOfficeManager.Id, so.Id);
        sel.SellerNumberNmb__c = '10586';
        update sel;
        
        MultiRequestMock mrm = new MultiRequestMock(new Map<String, StaticResourceCalloutMock>());
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Mock_ZPH_PREM');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        mrm.addRequestMock('ZPH_PREM', mock);
        
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        QuotaIntegrationUtils.getQuota(new List<Seller__c>{sel}, new List<Date>{Date.newInstance(2018, 1, 1)});
        QuotaIntegrationUtils.execBatchApex();
        Test.stopTest();
        
    }
    
    @isTest static void testReceivables(){
        TestData.createIntegrationData();
        RecordTypeMap rt = RecordTypeMap.getInstance();
 		String rtSAPAcc = rt.rtmap.get('Account').get('SAPBusinessAccount');
        Profile prof = [SELECT Id 
                        FROM Profile 
                        WHERE Name = 'Gerente de Vendas'];
        User salesOfficeManager = TestData.createUser('TestManager', null, null, prof.Id, 'testUser321@test.com');
        SalesOffice__c so = TestData.createSalesOffice('TestSalesOffice', salesOfficeManager.Id);
        Seller__c sel = TestData.createSeller('TestSeller', salesOfficeManager.Id, so.Id);
		Account acc = TestData.createAccount('TestAccount', null, null, rtSAPAcc);
        acc.CodeCustomerTxt__c = '0000100944';
        update acc;
        Channel__c channel = TestData.createChannel('VJ1', null);
        ExpeditionCenter__c expCenter = TestData.createExpeditionCenter('0070', '0700');
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acc.Id, channel.Id, sel.Id);
        
        MultiRequestMock mrm = new MultiRequestMock(new Map<String, StaticResourceCalloutMock>());
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Mock_ZPH_BSID');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        mrm.addRequestMock('ZPH_BSID', mock);
        
        Test.setMock(HttpCalloutMock.class, mrm);
        
        ReceivablesController.calcDelay('2018-01-01');
        
        Test.startTest();
        ReceivablesController.getReceivables(salesArea.Id);
        Test.stopTest();
        
    }
}