@isTest
private class Test_CreateVARequestItem {
    
    @isTest static void testCreateVA(){
        Channel__c chn = TestData.createChannel('TES', null);
        VerdeAmancoKit__c kit = TestData.createVerdeAmancoKit('TestKit', chn.Id);
        VerdeAmancoKitItem__c ki = TestData.createVerdeAmancoKitItem('TestKitItem', kit.Id, 2);
        chn.ActiveVerdeAmancoKitLkp__c = kit.Id;
        update chn;
        Account acct = TestData.createAccount('Test', chn.Id);
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acct.Id, chn.Id, null);
        VerdeAmancoSolicitation__c solic = TestData.createVerdeAmancoSolicitation('Test', salesArea.Id, 'Outro');
        ApexPages.StandardController stdController = new ApexPages.StandardController(solic);
        CreateVerdeAmancoRequestItem controller = new CreateVerdeAmancoRequestItem(stdController);    
        controller.saveSelected();
        //String cancelPage = controller.doCancel().getUrl();
        VerdeAmancoRequestItem__c ri = [Select Id, 	AmountNmb__c, VerdeAmancoKitItemLkp__c
                                        From VerdeAmancoRequestItem__c
                                        Where VerdeAmancoSolicitationIdLkp__c = :solic.Id];
        
        System.assertEquals(ki.Id, ri.VerdeAmancoKitItemLkp__c);
        System.assertEquals(ki.MaximumAmountNmb__c, ri.AmountNmb__c);
        //System.assertEquals('/' + solic.Id, cancelPage);
        //System.assertEquals('/' + solic.Id, savePage);


    } 

}