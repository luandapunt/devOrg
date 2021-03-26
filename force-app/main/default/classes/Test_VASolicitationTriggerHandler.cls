@isTest
private class Test_VASolicitationTriggerHandler {
    
    @isTest static void insertEnderecoConta(){
        Channel__c chn = TestData.createChannel('TES', null);
        VerdeAmancoKit__c kit = TestData.createVerdeAmancoKit('TestKit', chn.Id);
        chn.ActiveVerdeAmancoKitLkp__c = kit.Id;
        update chn;
        Account acct = TestData.createAccount('Test', chn.Id);
        acct.BillingStreet = 'Avenida das Nações Unidas';
        update acct;
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acct.Id, chn.Id, null);
        VerdeAmancoSolicitation__c solic = TestData.createVerdeAmancoSolicitation('Test', salesArea.Id, 'Endereço do Cliente');
        solic = [Select Id, ShippingAddressTxt__c, VerdeAmancoKitLkp__c 
                 From VerdeAmancoSolicitation__c
                 Where Id = :solic.Id];
        System.assertEquals('Avenida das Nações Unidas', solic.ShippingAddressTxt__c);
        System.assertEquals(kit.Id, solic.VerdeAmancoKitLkp__c);
        
    }
    
    @isTest static void insertEnderecoSolicitante(){
        Channel__c chn = TestData.createChannel('TES', null);
        VerdeAmancoKit__c kit = TestData.createVerdeAmancoKit('TestKit', chn.Id);
        chn.ActiveVerdeAmancoKitLkp__c = kit.Id;
        update chn;
        Account acct = TestData.createAccount('Test', chn.Id);
        update acct;
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acct.Id, chn.Id, null);
        VerdeAmancoSolicitation__c solic = TestData.createVerdeAmancoSolicitation('Test', salesArea.Id, 'Endereço do Solicitante');
        solic = [Select Id, ShippingAddressTxt__c, VerdeAmancoKitLkp__c 
                 From VerdeAmancoSolicitation__c
                 Where Id = :solic.Id];
        User solicitante = [Select Id, Street
                            From User
                            Where Id = :UserInfo.getUserId()];
        System.assertEquals(solicitante.Street, solic.ShippingAddressTxt__c);
        System.assertEquals(kit.Id, solic.VerdeAmancoKitLkp__c);
        
    }

    @isTest static void updateEnderecoConta(){
        Channel__c chn = TestData.createChannel('TES', null);
        VerdeAmancoKit__c kit = TestData.createVerdeAmancoKit('TestKit', chn.Id);
        chn.ActiveVerdeAmancoKitLkp__c = kit.Id;
        update chn;
        Account acct = TestData.createAccount('Test', chn.Id);
        acct.BillingStreet = 'Avenida das Nações Unidas';
        update acct;
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acct.Id, chn.Id, null);
        VerdeAmancoSolicitation__c solic = TestData.createVerdeAmancoSolicitation('Test', salesArea.Id, 'Outro');
        solic.AddressTypeTxt__c = 'Endereço do Cliente';  
        update solic;
        solic = [Select Id, ShippingAddressTxt__c, VerdeAmancoKitLkp__c 
                 From VerdeAmancoSolicitation__c
                 Where Id = :solic.Id];
        System.assertEquals('Avenida das Nações Unidas', solic.ShippingAddressTxt__c);
        
    }
    
    @isTest static void updateEnderecoOutro(){
        Channel__c chn = TestData.createChannel('TES', null);
        VerdeAmancoKit__c kit = TestData.createVerdeAmancoKit('TestKit', chn.Id);
        chn.ActiveVerdeAmancoKitLkp__c = kit.Id;
        update chn;
        Account acct = TestData.createAccount('Test', chn.Id);
        acct.BillingStreet = 'Avenida das Nações Unidas';
        update acct;
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acct.Id, chn.Id, null);
        VerdeAmancoSolicitation__c solic = TestData.createVerdeAmancoSolicitation('Test', salesArea.Id, 'Endereço do Cliente');
        solic.AddressTypeTxt__c = 'Outro';
        update solic;
        solic = [Select Id, ShippingAddressTxt__c, VerdeAmancoKitLkp__c 
                 From VerdeAmancoSolicitation__c
                 Where Id = :solic.Id];
        System.assertEquals(null, solic.ShippingAddressTxt__c);
    }
    
    @isTest static void updateEnderecoSolicitante(){
        Channel__c chn = TestData.createChannel('TES', null);
        VerdeAmancoKit__c kit = TestData.createVerdeAmancoKit('TestKit', chn.Id);
        chn.ActiveVerdeAmancoKitLkp__c = kit.Id;
        update chn;
        Account acct = TestData.createAccount('Test', chn.Id);
        acct.BillingStreet = 'Avenida Paulista';
        update acct;
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acct.Id, chn.Id, null);
        VerdeAmancoSolicitation__c solic = TestData.createVerdeAmancoSolicitation('Test', salesArea.Id, 'Endereço do Cliente');
        solic.AddressTypeTxt__c = 'Endereço do Solicitante';
        update solic;
        solic = [Select Id, ShippingAddressTxt__c, VerdeAmancoKitLkp__c, CreatedById 
                 From VerdeAmancoSolicitation__c
                 Where Id = :solic.Id];
        User solicitante = [Select Id, Street
                            From  User
                            Where Id = :solic.CreatedById];
        System.debug(solicitante.Street);
        System.assertEquals(solicitante.Street, solic.ShippingAddressTxt__c);
    }

    @isTest static void testFiles(){
        Channel__c chn = TestData.createChannel('TES', null);
        VerdeAmancoKit__c kit = TestData.createVerdeAmancoKit('TestKit', chn.Id);
        chn.ActiveVerdeAmancoKitLkp__c = kit.Id;
        update chn;
        Account acct = TestData.createAccount('Test', chn.Id);
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acct.Id, chn.Id, null);
        VerdeAmancoSolicitation__c solic = TestData.createVerdeAmancoSolicitation('Test', salesArea.Id, 'Outro');
        ContentVersion cv = TestData.createContentVersion('Header_Picture1', '/Header_Picture1.jpg');
       
        ContentVersion cv2 = [SELECT Id, Title, ContentDocumentId 
                              FROM ContentVersion 
                              WHERE Id = :cv.Id LIMIT 1];
        
        ContentDocumentLink cdl = TestData.createContentDocumentLink(cv2.ContentDocumentId, solic.Id);
        solic.StatusTxt__c = 'Aguardando envio';
        update solic;
        solic.StatusTxt__c = 'Aguardando aprovação';
        update solic;
        System.assertEquals('Aguardando aprovação', solic.StatusTxt__c);
            
    }

}