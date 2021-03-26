@isTest
private class ZTCaseInvoiceCtrl
{
    @isTest
    static void testManipulateCaseInvoice_one()
    {
        // Prepare test data
        RecordType recordType = [Select Id from RecordType where DeveloperName = 'BusinessAccountSAC' and SobjectType = 'Account'];
        
        Account account = new Account(Name = 'Testador da pagina', CNPJTxt__c = '26830528000181', RecordTypeId = recordType.Id);
        insert account;     
        
        recordType = [Select Id from RecordType where DeveloperName = 'ContactSAC' and SobjectType = 'Contact'];
        
        Contact contact = new Contact(FirstName = 'Testa', LastName = 'Tudo', AccountId = account.Id, RecordTypeId = recordType.Id);
        insert contact;
        
        Carrier__c carrier = new Carrier__c(Name = 'Transporta tudo', EmailTxt__c = 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = new Invoice__c(Name = '02568', CarrierLkp__c = carrier.Id);
        insert invoice;
        
        recordType = [Select Id from RecordType where DeveloperName = 'DuvidasTributarias' and SobjectType = 'Case'];
        
        Case caso = new Case(AccountId = account.Id, RecordTypeId = recordType.Id, ContactId = contact.Id, InvoiceLkp__c = invoice.id, Origin = 'Transportadora', ContactTypeTxt__c = 'Email', Status = 'Aberto', Type = 'Item');
        insert caso;
        
        CaseInvoice__c caseInvoice = new CaseInvoice__c(InvoiceLkp__c = invoice.Id, CaseMdt__c = caso.Id);
        insert caseInvoice;
        
        Invoice__c invoiceTwo = new Invoice__c(Name = '02569', AccountLkp__c = account.Id, CarrierLkp__c = carrier.Id);
        insert invoiceTwo;
        
        ApexRedirectMap__c apexRedirectMap = ULTestData.createApexRedirectMap('WebServiceInvoice', 'http://127.0.0.1:50000/xpto');
        insert apexRedirectMap;

        // Start Test
        System.Test.startTest();
        
        PageReference pageRef = Page.CaseInvoice;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(caseInvoice);
        Apexpages.currentPage().getParameters().put('id', String.valueOf(caseInvoice.Id));  
        
        CaseInvoiceCtrl caseInvoiceCtrl = new CaseInvoiceCtrl(sc);      
        caseInvoiceCtrl.invoiceNumber = '02569';        
        //caseInvoiceCtrl.insertInvoice();
        caseInvoiceCtrl.doSave();
    
        // Stop Test
        System.Test.stopTest();
    }

    @isTest
    static void testManipulateCaseInvoice_two()
    {
        // Prepare test data
        RecordType recordType = [Select Id from RecordType where DeveloperName = 'BusinessAccountSAC' and SobjectType = 'Account'];
        
        Account account = new Account(Name = 'Testador da pagina', CNPJTxt__c = '26830528000181', RecordTypeId = recordType.Id);
        insert account;     
        
        recordType = [Select Id from RecordType where DeveloperName = 'ContactSAC' and SobjectType = 'Contact'];
        
        Contact contact = new Contact(FirstName = 'Testa', LastName = 'Tudo', AccountId = account.Id, RecordTypeId = recordType.Id);
        insert contact;
        
        Carrier__c carrier = new Carrier__c(Name = 'Transporta tudo', EmailTxt__c = 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = new Invoice__c(Name = '02568', CarrierLkp__c = carrier.Id);
        insert invoice;
        
        recordType = [Select Id from RecordType where DeveloperName = 'CaminhaoRetido' and SobjectType = 'Case'];
        
        Case caso = new Case(AccountId = account.Id, RecordTypeId = recordType.Id, ContactId = contact.Id, InvoiceLkp__c = invoice.id, Origin = 'Transportadora', ContactTypeTxt__c = 'Email', Status = 'Aberto', Type = 'Item');
        insert caso;
        
        CaseInvoice__c caseInvoice = new CaseInvoice__c(InvoiceLkp__c = invoice.Id, CaseMdt__c = caso.Id);
        insert caseInvoice;
    
        // Start Test
        System.Test.startTest();
        
        PageReference pageRef = Page.CaseInvoice;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(caseInvoice);
        Apexpages.currentPage().getParameters().put('id', String.valueOf(caseInvoice.Id));  
        CaseInvoiceCtrl caseInvoiceCtrl = new CaseInvoiceCtrl(sc);
        caseInvoiceCtrl.invoiceNumber = '02569';        
        //caseInvoiceCtrl.insertInvoice();
        caseInvoiceCtrl.doSave();
    
        // Stop Test
        System.Test.stopTest();
    }

    @isTest
    static void testManipulateCaseInvoice_three()
    {
        // Prepare test data
        RecordType recordType = [Select Id from RecordType where DeveloperName = 'BusinessAccountSAC' and SobjectType = 'Account'];
        
        Account account = new Account(Name = 'Testador da pagina', CNPJTxt__c = '26830528000181', RecordTypeId = recordType.Id);
        insert account;     
        
        recordType = [Select Id from RecordType where DeveloperName = 'ContactSAC' and SobjectType = 'Contact'];
        
        Contact contact = new Contact(FirstName = 'Testa', LastName = 'Tudo', AccountId = account.Id, RecordTypeId = recordType.Id);
        insert contact;
        
        Carrier__c carrier = new Carrier__c(Name = 'Transporta tudo', EmailTxt__c = 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = new Invoice__c(Name = '02568', CarrierLkp__c = carrier.Id);
        insert invoice;
        
        recordType = [Select Id from RecordType where DeveloperName = 'SolicitacaoBoleto' and SobjectType = 'Case'];
        
        Case caso = new Case(AccountId = account.Id, RecordTypeId = recordType.Id, ContactId = contact.Id, InvoiceLkp__c = invoice.id, Origin = 'Transportadora', ContactTypeTxt__c = 'Email', Status = 'Aberto', Type = 'Item');
        insert caso;
        
        CaseInvoice__c caseInvoice = new CaseInvoice__c(InvoiceLkp__c = invoice.Id, CaseMdt__c = caso.Id);
        insert caseInvoice;

        // Start Test
        System.Test.startTest();
        
        PageReference pageRef = Page.CaseInvoice;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(caseInvoice);
        Apexpages.currentPage().getParameters().put('id', String.valueOf(caseInvoice.Id));  
        CaseInvoiceCtrl caseInvoiceCtrl = new CaseInvoiceCtrl(sc);
        caseInvoiceCtrl.invoiceNumber = '02569';        
        //caseInvoiceCtrl.insertInvoice();
        caseInvoiceCtrl.doSave();
    
        // Stop Test
        System.Test.stopTest();
    }

    @isTest
    static void testManipulateCaseInvoice_four()
    {
        // Prepare test data
        RecordType recordType = [Select Id from RecordType where DeveloperName = 'BusinessAccountSAC' and SobjectType = 'Account'];
        
        Account account = new Account(Name = 'Testador da pagina', CNPJTxt__c = '26830528000181', RecordTypeId = recordType.Id);
        insert account;     
        
        recordType = [Select Id from RecordType where DeveloperName = 'ContactSAC' and SobjectType = 'Contact'];
        
        Contact contact = new Contact(FirstName = 'Testa', LastName = 'Tudo', AccountId = account.Id, RecordTypeId = recordType.Id);
        insert contact;
        
        Carrier__c carrier = new Carrier__c(Name = 'Transporta tudo', EmailTxt__c = 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = new Invoice__c(Name = '02568', CarrierLkp__c = carrier.Id);
        insert invoice;        

        recordType = [Select Id from RecordType where DeveloperName = 'ProrrogacaoFluxoCaixa' and SobjectType = 'Case'];
        
        Case caso = new Case(AccountId = account.Id, RecordTypeId = recordType.Id, ContactId = contact.Id, InvoiceLkp__c = invoice.id, Origin = 'Transportadora', ContactTypeTxt__c = 'Email', Status = 'Aberto', Type = 'Item');
        insert caso;
        
        CaseInvoice__c caseInvoice = new CaseInvoice__c(InvoiceLkp__c = invoice.Id, CaseMdt__c = caso.Id);
        insert caseInvoice;

        // Start Test
        System.Test.startTest();
        
        PageReference pageRef = Page.CaseInvoice;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(caseInvoice);
        Apexpages.currentPage().getParameters().put('id', String.valueOf(caseInvoice.Id));  
        CaseInvoiceCtrl caseInvoiceCtrl = new CaseInvoiceCtrl(sc);
        caseInvoiceCtrl.invoiceNumber = '02569';        
        //caseInvoiceCtrl.insertInvoice();
        caseInvoiceCtrl.doSave();
        
        // Stop Test
        System.Test.stopTest();
    }

    @isTest
    static void testManipulateCaseInvoice_five()
    {
        // Prepare test data
        RecordType recordType = [Select Id from RecordType where DeveloperName = 'BusinessAccountSAC' and SobjectType = 'Account'];
        
        Account account = new Account(Name = 'Testador da pagina', CNPJTxt__c = '26830528000181', RecordTypeId = recordType.Id);
        insert account;     
        
        recordType = [Select Id from RecordType where DeveloperName = 'ContactSAC' and SobjectType = 'Contact'];
        
        Contact contact = new Contact(FirstName = 'Testa', LastName = 'Tudo', AccountId = account.Id, RecordTypeId = recordType.Id);
        insert contact;
        
        Carrier__c carrier = new Carrier__c(Name = 'Transporta tudo', EmailTxt__c = 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = new Invoice__c(Name = '02568', CarrierLkp__c = carrier.Id);
        insert invoice;
        
        recordType = [Select Id from RecordType where DeveloperName = 'AbatimentoCredito' and SobjectType = 'Case'];
        
        Case caso = new Case(AccountId = account.Id, RecordTypeId = recordType.Id, ContactId = contact.Id, InvoiceLkp__c = invoice.id, Origin = 'Transportadora', ContactTypeTxt__c = 'Email', Status = 'Aberto', Type = 'Item');
        insert caso;
        
        CaseInvoice__c caseInvoice = new CaseInvoice__c(InvoiceLkp__c = invoice.Id, CaseMdt__c = caso.Id);
        insert caseInvoice;

        // Start Test
        System.Test.startTest();
        
        PageReference pageRef = Page.CaseInvoice;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(caseInvoice);
        Apexpages.currentPage().getParameters().put('id', String.valueOf(caseInvoice.Id));  
        CaseInvoiceCtrl caseInvoiceCtrl = new CaseInvoiceCtrl(sc);
        caseInvoiceCtrl.doCancel();

        // Stop Test
        System.Test.stopTest();
    }

    @isTest
    static void testManipulateCaseInvoice_six()
    {
        // Prepare test data
        RecordType recordType = [Select Id from RecordType where DeveloperName = 'BusinessAccountSAC' and SobjectType = 'Account'];
        
        
        Account account = new Account(Name = 'Testador da pagina', CNPJTxt__c = '26830528000181', RecordTypeId = recordType.Id);
        insert account;     
        
        recordType = [Select Id from RecordType where DeveloperName = 'ContactSAC' and SobjectType = 'Contact'];
        
        Contact contact = new Contact(FirstName = 'Testa', LastName = 'Tudo', AccountId = account.Id, RecordTypeId = recordType.Id);
        insert contact;
        
        Carrier__c carrier = new Carrier__c(Name = 'Transporta tudo', EmailTxt__c = 'teste@transportatudo.com.br');
        insert carrier;
        
        Invoice__c invoice = new Invoice__c(Name = '02568', CarrierLkp__c = carrier.Id);
        insert invoice;
        
        recordType = [Select Id from RecordType where DeveloperName = 'NegociacaoDebito' and SobjectType = 'Case'];
        
        Case caso = new Case(AccountId = account.Id, RecordTypeId = recordType.Id, ContactId = contact.Id, InvoiceLkp__c = invoice.id, Origin = 'Transportadora', ContactTypeTxt__c = 'Email', Status = 'Aberto', Type = 'Item');
        insert caso;
        
        Channel__c channel = TestData.createChannel('TES', null); 
        
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(account.Id, channel.Id, null); 
        
        Order__c ordem = new Order__c(CustomIDTxt__c = 'abc123');
        ordem.AccountLkp__c = account.Id; 
        ordem.AccountAreaSalesLkp__c = salesArea.id; 
        insert ordem;
        
        CaseInvoice__c caseInvoice = new CaseInvoice__c(InvoiceLkp__c = invoice.Id, CaseMdt__c = caso.Id, OrderLkp__c = ordem.Id);
        insert caseInvoice;

        // Start Test
        System.Test.startTest();
        
        PageReference pageRef = Page.CaseInvoice;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(caseInvoice);
        Apexpages.currentPage().getParameters().put('id', String.valueOf(caseInvoice.Id));  
        
        CaseInvoiceCtrl caseInvoiceCtrl = new CaseInvoiceCtrl(sc);
        caseInvoiceCtrl.invoiceNumber = '02569';        
        //caseInvoiceCtrl.insertInvoice();
        caseInvoiceCtrl.listCaseInvoiceDAO[0].selected = true;
        caseInvoiceCtrl.removeInvoice();
        caseInvoiceCtrl.doSave();

        // Stop Test
        System.Test.stopTest();
    }
}