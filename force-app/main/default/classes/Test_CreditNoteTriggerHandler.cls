@isTest
private class Test_CreditNoteTriggerHandler {

    @isTest static void testCreditNote(){
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
        CreditNote__c cn = TestData.createCreditNote(acc.Id, null, campaing.id);

        System.assertEquals(salesArea.OwnersManagerFml__c, cn.ManagersManagerLkp__c);
    }
    
    @isTest static void testCreditNoteFile(){
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
        CreditNote__c cn = TestData.createCreditNote(acc.Id, null, campaing.id);
        ContentVersion cv = TestData.createContentVersion('Header_Picture1', '/Header_Picture1.jpg');
       
        ContentVersion cv2 = [SELECT Id, Title, ContentDocumentId 
                              FROM ContentVersion 
                              WHERE Id = :cv.Id LIMIT 1];
        
        ContentDocumentLink cdl = TestData.createContentDocumentLink(cv2.ContentDocumentId, cn.Id);
        cn.Type__c = 'Solicitação';
        update cn;
        cn.Status__c = 'Solicitado';
        update cn;
        System.assertEquals('Solicitado', cn.Status__c);
    }

}