@isTest
public class Test_CreditNoteIntegrationUtils {
    @isTest static void testCreateCreditNote(){
        TestData.createIntegrationData();
        RecordTypeMap rt = RecordTypeMap.getInstance();
 		String rtSACAcc = rt.rtmap.get('Account').get('BusinessAccountSAC');
        RecordTypeMap rtm = RecordTypeMap.getInstance();
 		String rtGroupAcc = rtm.rtmap.get('Account').get('CampaignGroup');
        Profile prof = [SELECT Id 
                        FROM Profile 
                        WHERE Name = 'Gerente de Vendas'];
        User salesOfficeManager = TestData.createUser('TestManager', null, null, prof.Id, 'testUser321@test.com');
        SalesOffice__c so = TestData.createSalesOffice('TestSalesOffice', salesOfficeManager.Id);
        Seller__c sel = TestData.createSeller('TestSeller', salesOfficeManager.Id, so.Id);
        Account acct = TestData.createAccount('Test Account', null, null, rtSACAcc);
        acct.CodeCustomerTxt__c = '12312321';
        update acct;
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acct.Id, null, sel.Id);
		Account acc = TestData.createAccount('Test', null, salesArea.Id, rtGroupAcc);
        Campaign__c campaing = TestData.createCampaign(Date.newInstance(2018, 01, 01), Date.newInstance(2018, 12, 31));
        CampaignAccount__c campaingAccount = TestData.createCampaignAccount(campaing, acc);
        CreditNote__c cn1 = TestData.createCreditNote(acc.Id, null, campaing.id);
        cn1.Type__c = 'Crédito Campanha';
        cn1.Value__c = 3000;
        update cn1;
        CreditNote__c cn2 = TestData.createCreditNote(acc.Id, null, campaing.id);
        //cn.TypeTxt__c = 'Valor solicitado';
        cn2.Value__c = 2000;
        cn2.InstallmentNumberNmb__c = 1;
        update cn2;
        
        MultiRequestMock mrm = new MultiRequestMock(new Map<String, StaticResourceCalloutMock>());
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Mock_CreateNc');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        mrm.addRequestMock('CreateNc', mock);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mrm);
        CreditNoteIntegrationUtils.createCreditNote(cn2.Id);
        Test.stopTest();
//        system.assertEquals('teste', cn2.ErrorMessageTxt__c);
    }
}