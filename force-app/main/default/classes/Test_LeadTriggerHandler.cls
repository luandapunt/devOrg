@isTest
private class Test_LeadTriggerHandler {

    @isTest static void isRegistered(){
        Profile prof = [SELECT Id 
                        FROM Profile 
                        WHERE Name = 'Gerente de Vendas'];
        User salesOfficeManager = TestData.createUser('TestManager', null, null, prof.Id, 'testUser321@test.com');
        SalesOffice__c so = TestData.createSalesOffice('TestSalesOffice', salesOfficeManager.Id);
        Seller__c sel = TestData.createSeller('TestSeller', null, so.Id);
        Lead l = TestData.createLead('TestCompany', null, sel.Id);
        Address__c add = new Address__c (Name = 'Rua 1', 
                                         Leadlkp__c = l.Id, 
                                         CNPJTxt__c = l.CNPJTxt__c, 
                                         CEPTxt__c = l.PostalCode,
                                         StateTxt__c = l.StateCode,
                                         PartnerStateInscriptionTxt__c = l.RG_StateInscriptionTxt__c,
                                         CityTxt__c = 'São Paulo',
                                         Phone__c = l.Phone
                                        );
        insert add;
        Account acc = TestData.createAccount('TestCompany', null);
        
        l.ConvertLeadBln__c = true;
        update l;
        l = [Select Id, RegisteredInDatabaseBln__c
             From Lead 
             Where Id =: l.Id];
        System.assertEquals(true, l.RegisteredInDatabaseBln__c);
        List<RecordType> rts = [SELECT Id 
                                FROM RecordType 
                                WHERE DeveloperName = 'SAPBusinessAccount' LIMIT 1];
        acc = [Select Id, RecordTypeId, CNPJTxt__c 
          	   From Account 
               Where Id =: acc.Id];
        System.assertEquals(rts[0].Id, acc.RecordTypeId);

    }
    
    @isTest static void testApprovalStep1(){
        Profile prof = [SELECT Id 
                        FROM Profile 
                        WHERE Name = 'Gerente de Vendas'];
        User salesOfficeManager = TestData.createUser('TestManager', null, null, prof.Id, 'testUser321@test.com');
        SalesOffice__c so = TestData.createSalesOffice('TestSalesOffice', salesOfficeManager.Id);
        Seller__c sel = TestData.createSeller('TestSeller', null, so.Id);
        Channel__c chn = TestData.createChannel('TES', null);
        Lead l = TestData.createLead('Nome de Teste', chn.Id, sel.Id);
        l.ApprovalTxt__C = 'Enviado para aprovação';
        l.ApprovalStatusTxt__C = 'Enviado para aprovação';
        update l;
        System.assertEquals('Enviado para aprovação', l.ApprovalTxt__c);
    }
    
    @isTest static void testApprovalStep2(){
        Profile prof = [SELECT Id 
                        FROM Profile 
                        WHERE Name = 'Gerente de Vendas'];
        User salesOfficeManager = TestData.createUser('TestManager', null, null, prof.Id, 'testUser321@test.com');
        SalesOffice__c so = TestData.createSalesOffice('TestSalesOffice', salesOfficeManager.Id);
        Seller__c sel = TestData.createSeller('TestSeller', null, so.Id);
        Channel__c chn = TestData.createChannel('TES', null);
        Lead l = TestData.createLead('Nome de Teste', chn.Id, sel.Id);
        l.ApprovalTxt__C = 'Aprovado na etapa 1';
        l.ApprovalStatusTxt__C = 'Aprovado na etapa 1';
        update l;
        System.assertEquals('Aprovado na etapa 1', l.ApprovalTxt__c);
    }
    
    @isTest static void testApprovalStep3(){
        Profile prof = [SELECT Id 
                        FROM Profile 
                        WHERE Name = 'Gerente de Vendas'];
        User salesOfficeManager = TestData.createUser('TestManager', null, null, prof.Id, 'testUser321@test.com');
        SalesOffice__c so = TestData.createSalesOffice('TestSalesOffice', salesOfficeManager.Id);
        Seller__c sel = TestData.createSeller('TestSeller', null, so.Id);
        Channel__c chn = TestData.createChannel('TES', null);
        Lead l = TestData.createLead('Nome de Teste', chn.Id, sel.Id);
        l.ApprovalTxt__C = 'Aprovado na etapa 2';
        l.ApprovalStatusTxt__C = 'Aprovado na etapa 2';
        update l;
        System.assertEquals('Aprovado na etapa 2', l.ApprovalTxt__c);
    }
}