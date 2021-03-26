@isTest
private class ZTRMTRemittanceBO {
    private static Map<String, Id> mapRecType;
    private static Seller__c seller;
    private static Account account;
    private static AccountAreaSales__c accountAreaSales;
    private static Contact contact;
    private static Carrier__c carrier;
    private static Product2 product;
    private static Invoice__c invoice;
    private static InvoiceItem__c invoiceItem;

    private static void init() {
        // Prepare test data
        mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
        
        seller = ULTestData.createSeller('John Doe', '1000');
        insert seller;
        
        account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        accountAreaSales = ULTestData.createAccountAreaSales(account.Id, seller.Id, '999333AM01RVPR00009090');
        insert accountAreaSales;
        
        contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        insert contact;
        
        carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        product = ULTestData.createProduct('FITA VIDEO', '900000000000001010');
        insert product;
        
        invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        invoiceItem = ULTestData.createInvoiceItem(invoice.Id, product.Id, '394368000010', 10);
        insert invoiceItem;
        
        
    }

    static testMEthod void testOne() {
        ZTRMTRemittanceBO.init();
        Case case1 = ULTestData.createCase(mapRecType.get('Reposicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        case1.OrderDevolutionStatusTxt__c = 'Processado completamente';
        insert case1;
        
        Order__c order1 = ULTestData.createOrder(account.Id, accountAreaSales.Id, '9998713');
        order1.CaseLkp__c = case1.Id;
        insert order1;
        
        Remittance__c remittance1 = ULTestData.createRemittance('name', null, '99902888A', Date.today(), Date.today());
        insert remittance1; 
    }

    static testMEthod void testTwo() {
        ZTRMTRemittanceBO.init();
        Case case2 = ULTestData.createCase(mapRecType.get('Sinistro'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        case2.OrderDevolutionStatusTxt__c = 'Processado completamente';
        case2.SinisterTxt__c = 'Total';
        insert case2;
        
        Order__c order2 = ULTestData.createOrder(account.Id, accountAreaSales.Id, '542245');
        order2.CaseLkp__c = case2.Id;
        insert order2;
        
        Remittance__c remittance2 = ULTestData.createRemittance('name', null, '42524554', Date.today(), Date.today());
        insert remittance2;    
    }

    static testMEthod void testThree() {
        ZTRMTRemittanceBO.init();
        Case case3 = ULTestData.createCase(mapRecType.get('Refaturamento'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        case3.OrderDevolutionStatusTxt__c = 'Processado completamente';
        //case3.SinisterTxt__c = 'Total';
        insert case3;
        
        Order__c order3 = ULTestData.createOrder(account.Id, accountAreaSales.Id, '45425542');
        order3.CaseLkp__c = case3.Id;
        insert order3;
        
        Remittance__c remittance3 = ULTestData.createRemittance('name', null, '425452', Date.today(), Date.today());
        insert remittance3;
        
    }

    static testMEthod void testFour() {
        ZTRMTRemittanceBO.init();
        Case case4 = ULTestData.createCase(mapRecType.get('ProdutoTrocado'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Quantidades iguais', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        case4.OrderDevolutionStatusTxt__c = 'Processado completamente';
        //case3.SinisterTxt__c = 'Total';
        insert case4;
        
        Order__c order4 = ULTestData.createOrder(account.Id, accountAreaSales.Id, '42454554');
        order4.CaseLkp__c = case4.Id;
        insert order4;
        
        Remittance__c remittance4 = ULTestData.createRemittance('name', null, '52445252', Date.today(), Date.today());
        insert remittance4;  

    }
    	
}