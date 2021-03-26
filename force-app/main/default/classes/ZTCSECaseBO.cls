@isTest
private class ZTCSECaseBO
{
    static testMethod void testSendEmail()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        insert contact;
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Reposicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Volume', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        insert caso;
        
        caso.Status = 'Cancelado';
        update caso;
        
        caso.Status = 'Em análise';
        update caso;
        
        caso.Status = 'Encerrado';
        caso.ClouseReasonTxt__c = 'Nota fiscal entregue';
        update caso;
      
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testSetInitialStatusReposicao()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
        
        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        insert contact;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case case1 = ULTestData.createCase(mapRecType.get('Reposicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        Case case2 = ULTestData.createCase(mapRecType.get('Reposicao'), account.Id, contact.Id, invoice.Id, 'Produto faltante', 'Aberto', 'Volume', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        Case case3 = ULTestData.createCase(mapRecType.get('Reposicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Volume', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        insert new List<Case>{case1, case2, case3};
        
        // Stop Test
        System.Test.stopTest();
        
        // Verify data
        Map<Id, Case> caseById = CaseDAO.selectByIdSet(new Set<Id>{case1.Id, case2.Id, case3.Id});
        System.assert(caseById.get(case1.Id).Status == 'Aberto', 'caseById.get(case1.Id).Status='+caseById.get(case1.Id).Status);
        //System.assert(caseById.get(case2.Id).Status == 'Aberto', 'caseById.get(case2.Id).Status='+caseById.get(case2.Id).Status);
        System.assert(caseById.get(case3.Id).Status == 'Aguardando retorno transportadora', 'caseById.get(case3.Id).Status='+caseById.get(case3.Id).Status);
    }
    
    
    static testMethod void testSetEntitlement()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
        
        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Entitlement entitlement = ULTestData.createEntitlement(account.Id, 'Name');
        insert entitlement;
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        insert contact;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        Case aCase1 = ULTestData.createCase(mapRecType.get('Reposicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        Case aCase2 = ULTestData.createCase(mapRecType.get('Substituicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        Case aCase3 = ULTestData.createCase(mapRecType.get('Devolucao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        Case aCase4 = ULTestData.createCase(mapRecType.get('ConsultaPedido'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Em análise', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        Case aCase5 = ULTestData.createCase(mapRecType.get('ExtravioNotaFiscal'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        Case aCase6 = ULTestData.createCase(mapRecType.get('Sinistro'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        Case aCase7 = ULTestData.createCase(mapRecType.get('Sustacao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Em análise', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        Case aCase8 = ULTestData.createCase(mapRecType.get('Refaturamento'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aguardando parecer do setor', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        Case aCase9 = ULTestData.createCase(mapRecType.get('CartaCorrecao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        Case aCase10 = ULTestData.createCase(mapRecType.get('AlteracaoPedido'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        Case aCase11 = ULTestData.createCase(mapRecType.get('IndicacaoVendedor'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        Case aCase12 = ULTestData.createCase(mapRecType.get('IndicacaoBNDES'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        Case aCase13 = ULTestData.createCase(mapRecType.get('Reclamacao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        Case aCase14 = ULTestData.createCase(mapRecType.get('DuvidaTecnica'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        Case aCase15 = ULTestData.createCase(mapRecType.get('CaminhaoRetido'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        Case aCase16 = ULTestData.createCase(mapRecType.get('DuvidasTributarias'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        Case aCase17 = ULTestData.createCase(mapRecType.get('SolicitacaoBoleto'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        Case aCase18 = ULTestData.createCase(mapRecType.get('ProrrogacaoFluxoCaixa'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        Case aCase19 = ULTestData.createCase(mapRecType.get('AbatimentoCredito'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        Case aCase20 = ULTestData.createCase(mapRecType.get('NegociacaoDebito'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        Case aCase21 = ULTestData.createCase(mapRecType.get('PortalNeogrid'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        Case aCase22 = ULTestData.createCase(mapRecType.get('ProdutoTrocado'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aguardando retorno trasportadora', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        
        // Start Test
        System.Test.startTest();
        
        try {
            Database.insert(new List<Case>{aCase1, aCase2, aCase3, aCase4, aCase5, aCase6, aCase7, aCase8, aCase9, aCase10, aCase11, aCase12, aCase13, aCase14, aCase15, aCase16, aCase17, aCase18, aCase19, aCase20, aCase21, aCase22}, false);
        }
        catch (Exception ex) {
            // ignores validation erros
        }
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeDevolucao_StatusQMEmAndamento()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Devolucao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Volume', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Em análise';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        insert caso;
        
        caso.Status = 'QM em andamento';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeReposicao_StatusEncerrado()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Reposicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Volume', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Encerrado';
        caso.ClouseReasonTxt__c = 'Crédito liberado';
        caso.Type = 'Volume';
        caso.NotSendemailBln__c = false;
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeReposicao_StatusAguardandoNotaFiscalDeDevolucao()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Reposicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Volume', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Aguardando nota fiscal de devolução';
        caso.Type = 'Volume';
        caso.NotSendemailBln__c = false;
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeReposicao_StatusAguardandoNotaFiscalDeDevolucao_ProdutoFaltante()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Reposicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'VolumeXXX', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Aguardando nota fiscal de devolução';
        caso.Type = 'VolumeXXX';
        caso.NotSendemailBln__c = false;
        caso.Reason = 'Produto faltante';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeReposicao_StatusOrdemDeReposicaoCriada()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Reposicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Volume', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Ordem de reposição criada';
        caso.Type = 'Volume';
        caso.NotSendemailBln__c = false;
        caso.SectorEmailEml__c = 'setor@testemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeReposicao_StatusCancelado()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Reposicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aguardando encerramento', 'Volume', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Cancelado';
        caso.ClouseReasonTxt__c = 'Reclamação não procede';
        caso.Type = 'Volume';
        caso.NotSendemailBln__c = false;
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeReposicaoStatusAguardandoNotaFiscalDeFevolucao()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Reposicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Aguardando nota fiscal de devolução';
        caso.Reason = 'X';
        caso.Type = 'Item';
        caso.NotSendemailBln__c = false;
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeReposicao_StatusEncerrado_ClouseReasonCreditoLiberado()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Reposicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Encerrado';
        caso.ClouseReasonTxt__c = 'Crédito liberado';
        caso.Type = 'Item';
        caso.NotSendemailBln__c = false;
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }

    static testMethod void testCaseRecTypeReposicao_StatusEncerrado_ClouseReasonCreditoLiberadoVolume()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Reposicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Volume', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Encerrado';
        caso.ClouseReasonTxt__c = 'Crédito liberado';
        caso.Type = 'Volume';
        caso.NotSendemailBln__c = false;
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeReposicao_StatusEmAnalise()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Reposicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Em análise';
        caso.ClouseReasonTxt__c = '';
        caso.Type = 'Item';
        caso.NotSendemailBln__c = false;
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeReposicao_StatusOrdemDeReposicaoCriada_TypeItem()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Reposicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Ordem de reposição criada';
        caso.ClouseReasonTxt__c = '';
        caso.Type = 'Item';
        caso.NotSendemailBln__c = false;
        caso.SectorEmailEml__c = 'setor@testemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeReposicao_StatusEncerrado_ClouseReason()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Reposicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Encerrado';
        caso.ClouseReasonTxt__c = 'Nota fiscal entregue';
        caso.Type = 'Item';
        caso.NotSendemailBln__c = false;
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypePortalNeogrid_StatusEncerrado_IsRegisterNeogridNao()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('PortalNeogrid'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Encerrado';
        caso.ClouseReasonTxt__c = '';
        caso.IsRegisterNeogridTxt__c = 'Não';
        caso.Type = 'Item';
        caso.NotSendemailBln__c = false;
        caso.EmailAccountAlternativeTxt__c = 'alternative@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypePortalNeogrid_StatusEncerrado_IsRegisterNeogridSim()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('PortalNeogrid'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Encerrado';
        caso.ClouseReasonTxt__c = '';
        caso.IsRegisterNeogridTxt__c = 'Sim';
        caso.Type = 'Item';
        caso.NotSendemailBln__c = false;
        caso.EmailAccountAlternativeTxt__c = 'alternative@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    static testMethod void testCaseRecTypeReclamacao_StatusAguardandoParecerDeCampo()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Reclamacao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        caso.Status = 'Aberto';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Aguardando parecer de campo';
        caso.NotSendemailBln__c = false;
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }

    static testMethod void testCaseRecTypeReclamacao_StatusAguardandoAmostra()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Reclamacao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        caso.Status = 'Aberto';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Aguardando amostra';
        caso.NotSendemailBln__c = false;
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }

    static testMethod void testCaseRecTypeSolicitacaoBoleto_StatusEncerrado()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('SolicitacaoBoleto'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Encerrado';
        caso.ClouseReasonTxt__c = '';
        caso.Type = 'Item';
        caso.NotSendemailBln__c = false;
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeProrrogacaoFluxoCaixa_StatusEncerrado()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('ProrrogacaoFluxoCaixa'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Encerrado';
        caso.ClouseReasonTxt__c = '';
        caso.Type = 'Item';
        caso.NotSendemailBln__c = false;
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeCancelamentoPedido_StatusAguardandoParecerDoSetor()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('CancelamentoPedido'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Aguardando parecer do setor';
        caso.ClouseReasonTxt__c = '';
        caso.Type = 'Cancelamento com remessa';
        caso.NotSendemailBln__c = false;
        caso.SectorEmailEml__c = 'sector@testeemail.com.br';
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeCancelamentoPedido_StatusEncerrado_TypeCancelamentoComRemessa()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('CancelamentoPedido'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Encerrado';
        caso.ClouseReasonTxt__c = '';
        caso.Type = 'Cancelamento com remessa';
        caso.NotSendemailBln__c = false;
        caso.SectorEmailEml__c = 'sector@testeemail.com.br';
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeCancelamentoPedido_StatusEncerrado_TypeCancelamentoSemRemessa()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('CancelamentoPedido'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Encerrado';
        caso.ClouseReasonTxt__c = '';
        caso.Type = 'Cancelamento sem remessa';
        caso.NotSendemailBln__c = false;
        caso.SectorEmailEml__c = 'sector@testeemail.com.br';
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeIndicacaoBNDES_StatusEncerrado()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('IndicacaoBNDES'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Encerrado';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.EmailAccountAlternativeTxt__c = 'alternative@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeIndicacaoVendedor_StatusEncerrado()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('IndicacaoVendedor'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Encerrado';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeAlteracaoPedido_StatusEncerrado()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('AlteracaoPedido'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Encerrado';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeCartaCorrecao_StatusAguardandoParecerDoSetor()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('CartaCorrecao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        caso.Reason = 'Endereço de entrega';
        insert caso;
        
        caso.Status = 'Aguardando parecer do setor';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.EmailResponsibleTaxEml__c = 'responsible@testeemail.com.br';
        caso.EmailResponsibleLogisticEml__c = 'responsibleLogistics@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeCartaCorrecao_StatusEncerrado()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('CartaCorrecao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Encerrado';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.EmailResponsibleTaxEml__c = 'responsible@testeemail.com.br';
        caso.EmailResponsibleLogisticEml__c = 'responsibleLogistics@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeRefaturamento_StatusAguardandoParecerDoSetor_TypeDivergenciaFiscal()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Refaturamento'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Aguardando parecer do setor';
        caso.TaxStatusTxt__c = 'Contribuinte';
        caso.Type = 'Divergência fiscal';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeRefaturamento_StatusAguardandoNotaFiscalDeDevolucao()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Refaturamento'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Aguardando nota fiscal de devolução';
        caso.TaxStatusTxt__c = 'Contribuinte';
        caso.Type = 'Divergência fiscal';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeRefaturamento_StatusEncerrado()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Refaturamento'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Encerrado';
        caso.TaxStatusTxt__c = 'Contribuinte';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeRefaturamento_StatusAguardandoParecerDoSetor_TypeDivergenciaDeValoresPricing()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Refaturamento'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Aguardando parecer do setor';
        caso.Type = 'Divergência de valores - pricing';
        caso.TaxStatusTxt__c = 'Contribuinte';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        caso.SectorEmailEml__c = 'sector@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeRefaturamento_StatusAguardandoNotaFiscalDeDevolucao_TypeDivergenciaDeValoresPricing()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Refaturamento'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Aguardando nota fiscal de devolução';
        caso.Type = 'Divergência de valores - pricing';
        caso.TaxStatusTxt__c = 'Contribuinte';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        caso.SectorEmailEml__c = 'sector@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeRefaturamento_StatusAguardandoParecerDoSetor_TypeMudancaDeCNPJ()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Refaturamento'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Aguardando parecer do setor';
        caso.Type = 'Mudança de CNPJ';
        caso.TaxStatusTxt__c = 'Contribuinte';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeRefaturamento_StatusAguardandoNotaFiscalDeDevolucao_TypeMudancaDeCNPJ()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Refaturamento'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Aguardando nota fiscal de devolução';
        caso.Type = 'Mudança de CNPJ';
        caso.TaxStatusTxt__c = 'Contribuinte';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeRefaturamento_StatusEncerrado_TaxTypeNaoContribuinte()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Refaturamento'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Encerrado';
        caso.TaxStatusTxt__c = 'Não contribuinte';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        caso.SectorEmailEml__c = 'sector@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeReclamacaoContraVendedor_StatusEncerrado()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('ReclamacaoContraVendedor'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Encerrado';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        caso.SectorEmailEml__c = 'sector@testeemail.com.br';
        update caso;
        
        caso.Status = 'Aguardando parecer de campo';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        caso.SectorEmailEml__c = 'sector@testeemail.com.br';
        update caso;
        
        caso.Status = 'Aguardando amostra';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        caso.SectorEmailEml__c = 'sector@testeemail.com.br';
        update caso;
        
        caso.Status = 'Enviado para laboratório';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        caso.SectorEmailEml__c = 'sector@testeemail.com.br';
        update caso;
        
        caso.Status = 'Aguardando documentos do campo';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        caso.SectorEmailEml__c = 'sector@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeSinistro_StatusAguardandoRetornoTransportadora_SinisterTxtParcial()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Sinistro'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Aguardando retorno transportes';
        caso.SinisterTxt__c = 'Parcial';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        caso.SectorEmailEml__c = 'sector@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest(); 
    }
    static testMethod void testCaseRecTypeSinistro_StatusAguardandoRetornoTransportes_SinisterTxtParcial()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Sinistro'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Aguardando retorno transportes';
        caso.SinisterTxt__c = 'Parcial';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        caso.SectorEmailEml__c = 'sector@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeSinistro_StatusAguardandoRetornoTransportadora_SinisterTxtTotal()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Sinistro'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Aguardando retorno transportes';
        caso.SinisterTxt__c = 'Total';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        caso.SectorEmailEml__c = 'sector@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeSinistro_StatusEncerrado_SinisterTxtTotal()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Sinistro'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aguardando retorno transportes', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Encerrado';
        caso.SinisterTxt__c = 'Total';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        caso.SectorEmailEml__c = 'sector@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeSinistro_StatusEncerrado_SinisterTxtParcial()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Sinistro'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Encerrado';
        caso.SinisterTxt__c = 'Parcial';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        caso.SectorEmailEml__c = 'sector@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeExtravioNotaFiscal_StatusAguardandoRetornoTransportadora()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('ExtravioNotaFiscal'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Aguardando retorno transportadora';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        caso.SectorEmailEml__c = 'sector@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeExtravioNotaFiscal_StatusEncerrado()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('ExtravioNotaFiscal'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Encerrado';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        caso.SectorEmailEml__c = 'sector@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeExtravioNotaFiscal_StatusOrdemDeVendaCriada()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('ExtravioNotaFiscal'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Ordem de venda criada';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CarrierEmailEml__c = 'carrier@testeemail.com.br';
        caso.SectorEmailEml__c = 'sector@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    
    static testMethod void testCaseRecTypeProdutoTrocado_StatusEmAnalise()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('ProdutoTrocado'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        caso.Type = 'Quantidades diferentes';
        insert caso;
        
        caso.Status = 'Aguardando retorno transportadora';
        //caso.Type = 'Quantidades iguais';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CarrierEmailEml__c = 'carrier@testeemail.com.br';
        update caso;
        
        caso.Status = 'Aguardando retorno transportadora';
        caso.Type = 'Quantidades iguais';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CarrierEmailEml__c = 'carrier@testeemail.com.br';
        update caso;
        
        caso.Status = 'Aguardando nota fiscal de devolução';
        caso.Type = 'Quantidades iguais';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CarrierEmailEml__c = 'carrier@testeemail.com.br';
        update caso;
        
        caso.Status = 'Aguardando nota fiscal de devolução';
        caso.Type = 'Quantidades diferentes';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CarrierEmailEml__c = 'carrier@testeemail.com.br';
        update caso;
        
        caso.Status = 'Ordem de substituição criada';
        caso.Type = 'Quantidades iguais';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CarrierEmailEml__c = 'carrier@testeemail.com.br';
        update caso;
        // Stop Test
        System.Test.stopTest();
    }
    
    /*
    static testMethod void testCaseRecTypeProdutoTrocado_StatusAguardandoRetornoTransportadora()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('ProdutoTrocado'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Aguardando retorno transportadora';
        caso.Type = 'Quantidades diferentes';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CarrierEmailEml__c = 'carrier@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    */
    
    /*
    // System.DmlException: Update failed. First exception on row 0 with id 5005500000381ofAAA; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, 
    // Prorrogação por negociação comercial: alteração de status não permitida.: []
    static testMethod void testCaseRecTypeProrrogacao_StatusQMEmAndamento()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Prorrogacao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        caso.Status = 'Em análise';
        caso.DeliveryTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.Type = 'Negociação comercial';
        insert caso;
        
        caso.Status = 'QM em andamento';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CarrierEmailEml__c = 'carrier@testeemail.com.br';
        caso.SectorEmailEml__c = 'sector@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    */
    
    /*
    // System.DmlException: Update failed. First exception on row 0 with id 5005500000381okAAA; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, 
    // Prorrogação: alteração de status não permitida.: []
    static testMethod void testCaseRecTypeProrrogacao_StatusEncerrado()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Prorrogacao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        caso.Status = 'Em análise';
        caso.DeliveryTxt__c = '';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Encerrado';
        caso.ClouseReasonTxt__c = '';
        caso.NotSendemailBln__c = false;
        caso.CarrierEmailEml__c = 'carrier@testeemail.com.br';
        caso.SectorEmailEml__c = 'sector@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    */
    
    static testMethod void testCaseRecTypeProrrogacao_StatusCancelado()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Prorrogacao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Em análise';
        caso.DeliveryTxt__c = '';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Cancelado';
        caso.ClouseReasonTxt__c = 'Reclamação não procede';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeDevolucao_StatusEmAnalise()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Devolucao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Em análise';
        caso.ClouseReasonTxt__c = 'Reclamação não procede';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeDevolucao_StatusOrdemDeDevolucaoCriada()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Devolucao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Ordem de devolução criada';
        caso.ClouseReasonTxt__c = 'Reclamação não procede';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeDevolucao_StatusEncerrado()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Devolucao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Pós';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Encerrado';
        caso.ClouseReasonTxt__c = 'Reclamação não procede';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeDevolucao_StatusAguardandoRetornoVendedor()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Devolucao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Ato';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Aguardando retorno vendedor';
        caso.Type = 'Total';
        caso.ClouseReasonTxt__c = 'Reclamação não procede';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeDevolucao_StatusEncerrado2()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Devolucao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Ato';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Encerrado';
        caso.Type = 'Total';
        caso.ClouseReasonTxt__c = 'Revertido vendedor';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    /*
    // System.DmlException: Update failed. First exception on row 0 with id 5005500000381prAAA; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, 
    // Devolução 1 Ato: alteração de status não permitida.: []
    static testMethod void testCaseRecTypeDevolucao_StatusOrdemDeDevolucaoSimbolicaCriada()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Devolucao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Ato';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Ordem de devolução simbólica criada';
        caso.Type = 'Total';
        caso.ClouseReasonTxt__c = 'Revertido vendedor';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    */
    
    /*
    // System.DmlException: Update failed. First exception on row 0 with id 5005500000381qBAAQ; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, 
    // Devolução 1 Ato: alteração de status não permitida.: []
    static testMethod void testCaseRecTypeDevolucao_StatusOrdemDeDevolucaoCriada2()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Devolucao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Ato';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Ordem de devolução criada';
        caso.Type = 'Total';
        caso.ClouseReasonTxt__c = 'Revertido vendedor';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    */
    
    /*
    // System.DmlException: Update failed. First exception on row 0 with id 5005500000381qQAAQ; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, 
    // Devolução 1 Ato: alteração de status não permitida.: []
    static testMethod void testCaseRecTypeDevolucao_StatusRevertidoVendedor_TypeParcial()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Devolucao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Ato';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Revertido vendedor';
        caso.Type = 'Parcial';
        caso.ClouseReasonTxt__c = 'Revertido vendedor';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    */
    
    static testMethod void testCaseRecTypeSubstituicao_StatusAguardandoRetornoTransportadora()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Substituicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Ato';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Aguardando retorno transportadora';
        caso.DamageTypeTxt__c = 'Transportadora';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
    
    static testMethod void testCaseRecTypeSubstituicao_StatusEncerrado()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        contact.Email = 'contact1@testemail.com.br';
        
        Contact contactMailUserCase = ULTestData.createContact(mapRecType.get('SAPContact'), null, '', 'MailUserCase');
        contactMailUserCase.Email = 'MailUserCase@testemail.com.br';
        insert new List<Contact>{contact, contactMailUserCase};
        
        Contact contactEmail = ULTestData.createContact(mapRecType.get('SAPContact'), account.Id, '', 'MailUserCase');
        insert contactEmail;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        // Start Test
        System.Test.startTest();
        
        Case caso = ULTestData.createCase(mapRecType.get('Substituicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com','email@alternativo1.com','email@alternativo2.com');
        caso.Status = 'Aberto';
        caso.DeliveryTxt__c = 'Ato';
        caso.NotSendemailBln__c = false;
        insert caso;
        
        caso.Status = 'Encerrado';
        caso.ClouseReasonTxt__c = 'Reclamação procede - valor baixo';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        update caso;
        
        caso.Status = 'Ordem de substituição criada';
        caso.ClouseReasonTxt__c = 'Reclamação procede - valor baixo';
        caso.NotSendemailBln__c = false;
        caso.CoordinatorSellerEmailEml__c = 'coordinator@testeemail.com.br';
        caso.ManagerEmailEml__c = 'manager@testeemail.com.br';
        update caso;
        
        // Stop Test
        System.Test.stopTest();
    }
}