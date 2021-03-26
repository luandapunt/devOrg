@isTest
public class Test_AccountIntegrationUtils {

    @isTest static void testCreditLimit(){
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
        acc.CodeCustomerTxt__c = '212396';
        update acc;
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Mock_ZPH_CRED');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        CreditLimitIntegrationUtils.getCreditLimit(new List<Id>{acc.Id});
        Test.stopTest();
        acc = [SELECT CreditLimit__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(2000000, acc.CreditLimit__c);
        
    }
    
    @isTest static void testAccount(){
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
        acc.CodeCustomerTxt__c = '';
        acc.SuframaCodeTxt__c = '10';
        acc.LeadSellerLkp__c = sel.Id;
        acc.LeadSalesOrganizationTxt__c = '0099';
        update acc;
        //Account partner = TestData.createAccount('TestPartner', null, null, rt.rtmap.get('Account').get('AccountPartner'));
        //partner.CodeCustomerTxt__c = '';
        //update partner;
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Mock_Customer');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        AccountIntegrationUtils.resendAccount(acc.Id);
        //AccountIntegrationUtils.createPartner(partner.Id, acc.Id);
        Test.stopTest();
        acc = AccountIntegrationUtils.getAccount(acc.Id);
    }
    
    @isTest static void testPartner(){
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
        acc.LeadSellerLkp__c = sel.Id;
        update acc;
        Account partner = TestData.createAccount('TestPartner', null, null, rt.rtmap.get('Account').get('AccountPartner'));
       // partner.CNPJTxt__c = acc.CNPJTxt__c;
       // partner.BillingStateCode = acc.BillingStateCode;
       // partner.BillingState = acc.BillingState;
       // partner.RG_StateInscriptionTxt__c = acc.RG_StateInscriptionTxt__c;
        partner.Name = acc.Name;
        
        partner.CodeCustomerTxt__c = '';
        partner.ParentId = acc.Id;
                
        update partner;
        
        MultiRequestMock mrm = new MultiRequestMock(new Map<String, StaticResourceCalloutMock>());

        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Mock_Customer_Partner');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        mrm.addRequestMock('Customer', mock);
        
        /*mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Mock_Customer_AssociatePartner');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        mrm.addRequestMock('Customer', mock);*/
        
        Test.setMock(HttpCalloutMock.class, mrm);
        
        Test.startTest();
        //AccountIntegrationUtils.resendAccount(acc.Id);
        AccountIntegrationUtils.createPartner(partner.Id, acc.Id);
        Test.stopTest();
    }
    
    @isTest static void associatePartner(){
        TestData.createIntegrationData();
        RecordTypeMap rt = RecordTypeMap.getInstance();
 		String rtSAPAcc = rt.rtmap.get('Account').get('SAPBusinessAccount');
        Profile prof = [SELECT Id 
                        FROM Profile 
                        WHERE Name = 'Gerente de Vendas'];
        User salesOfficeManager = TestData.createUser('TestManager', null, null, prof.Id, 'testUser321@test.com');
        SalesOffice__c so = TestData.createSalesOffice('TestSalesOffice', salesOfficeManager.Id);
        Seller__c sel = TestData.createSeller('TestSeller', salesOfficeManager.Id, so.Id);
		Account acc = TestData.createAccount('TestAcc', null, null, rtSAPAcc);
        acc.CodeCustomerTxt__c = acc.CodeCustomerTxt__c + 'Partner';
        
        acc.LeadSellerLkp__c = sel.Id;
        update acc;
        Account partner = TestData.createAccount('TestAcc', null, null, rt.rtmap.get('Account').get('AccountPartner'));
        partner.ParentId = acc.Id;
        update partner;
        
        MultiRequestMock mrm = new MultiRequestMock(new Map<String, StaticResourceCalloutMock>());

        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Mock_Customer_AssociatePartner');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        mrm.addRequestMock('Customer', mock);
        
        Test.setMock(HttpCalloutMock.class, mrm);
        
        Test.startTest();
        AccountIntegrationUtils.associatePartner(new List<Id>{partner.Id});
        Test.stopTest();
    }
   
}