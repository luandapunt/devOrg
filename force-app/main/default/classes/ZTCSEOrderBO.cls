@isTest
private class ZTCSEOrderBO
{
    static testMethod void testOrderSubstituicao()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
    	Seller__c seller = ULTestData.createSeller('John Doe', '1000');
    	insert seller;
    	
    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	insert account;    	
    	
    	AccountAreaSales__c accountAreaSales = ULTestData.createAccountAreaSales(account.Id, seller.Id, '999333AM01RVPR00009090');
    	insert accountAreaSales;
    	
    	Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
    	insert contact;
    	
    	Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
    	insert carrier;
    	
    	Product2 product = ULTestData.createProduct('FITA VIDEO', '900000000000001010');
    	insert product;
    	
    	Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
    	insert invoice;
    	
    	InvoiceItem__c invoiceItem = ULTestData.createInvoiceItem(invoice.Id, product.Id, '394368000010', 10);
    	insert invoiceItem;
    	
    	Case case1 = ULTestData.createCase(mapRecType.get('Substituicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aguardando nota fiscal de devolução', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	insert case1;
    	
    	// Start Test
		System.Test.startTest();
		
		Order__c order1 = ULTestData.createOrder(account.Id, accountAreaSales.Id, '9998713');
    	order1.CaseLkp__c = case1.Id;
    	order1.OrderStatusTxt__c = 'Cancelada';
    	insert order1;
    	
    	order1.OrderStatusTxt__c = 'Cancelada';
    	update order1;
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(order1 != null);
    }
    
    static testMethod void testOrderRefaturamento()
    {
        // Prepare test data
        Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
        
        Seller__c seller = ULTestData.createSeller('John Doe', '1000');
        insert seller;
        
        Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
        insert account;     
        
        AccountAreaSales__c accountAreaSales = ULTestData.createAccountAreaSales(account.Id, seller.Id, '999333AM01RVPR00009090');
        insert accountAreaSales;
        
        Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
        insert contact;
        contact.Email = 'teste@testecontato.com';
        update contact;
        
        Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
        insert carrier;
        
        Product2 product = ULTestData.createProduct('FITA VIDEO', '900000000000001010');
        insert product;
        
        Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
        insert invoice;
        
        InvoiceItem__c invoiceItem = ULTestData.createInvoiceItem(invoice.Id, product.Id, '394368000010', 10);
        insert invoiceItem;
        
        Case case1 = ULTestData.createCase(mapRecType.get('Refaturamento'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aguardando nota fiscal de devolução', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
        insert case1;
        
        // Start Test
        System.Test.startTest();
        
        Order__c order1 = ULTestData.createOrder(account.Id, accountAreaSales.Id, '9998713');
        order1.CaseLkp__c = case1.Id;
        order1.OrderStatusTxt__c = 'Não processado';
        order1.OrderTypeTxt__c = 'ZDOP';
        insert order1;
        
        order1.OrderStatusTxt__c = 'Processado complatamente';
        update order1;

        Order__c order2 = ULTestData.createOrder(account.Id, accountAreaSales.Id, '9998714');
        order2.CaseLkp__c = case1.Id;
        order2.OrderStatusTxt__c = 'Não processado';
        order2.OrderTypeTxt__c = 'ZDSO';
        insert order2;
        
        order2.OrderStatusTxt__c = 'Processado complatamente';
        update order2;
        
        
        // Stop Test
        System.Test.stopTest();
        
        // Verify data
        System.assert(order1 != null);
    }
    
    static testMethod void testSetStatusCase()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
    	Seller__c seller = ULTestData.createSeller('John Doe', '1000');
    	insert seller;
    	
    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	insert account;    	
    	
    	AccountAreaSales__c accountAreaSales = ULTestData.createAccountAreaSales(account.Id, seller.Id, '999333AM01RVPR00009090');
    	insert accountAreaSales;
    	
    	Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
    	insert contact;
    	
    	Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
    	insert carrier;
    	
    	Product2 product = ULTestData.createProduct('FITA VIDEO', '900000000000001010');
    	insert product;
    	
    	Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
    	insert invoice;
    	
    	InvoiceItem__c invoiceItem = ULTestData.createInvoiceItem(invoice.Id, product.Id, '394368000010', 10);
    	insert invoiceItem;
    	
    	Case case1 = ULTestData.createCase(mapRecType.get('Substituicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aguardando nota fiscal de devolução', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	insert case1;
    	
    	Order__c order1 = ULTestData.createOrder(account.Id, accountAreaSales.Id, '9998713');
    	order1.CaseLkp__c = case1.Id;
    	order1.OrderStatusTxt__c = 'Cancelada';
    	insert order1;
    	
    	// Start Test
		System.Test.startTest();
		
    	CSEOrderBO orderBO = new CSEOrderBO();
    	orderBO.setStatusCase(new List<Order__c>{order1});
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(order1 != null);
    }
    
    static testMethod void testOrderReposicao_StatusAberto()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
    	Seller__c seller = ULTestData.createSeller('John Doe', '1000');
    	insert seller;
    	
    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	insert account;    	
    	
    	AccountAreaSales__c accountAreaSales = ULTestData.createAccountAreaSales(account.Id, seller.Id, '999333AM01RVPR00009090');
    	insert accountAreaSales;
    	
    	Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
    	insert contact;
    	
    	Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
    	insert carrier;
    	
    	Product2 product = ULTestData.createProduct('FITA VIDEO', '900000000000001010');
    	insert product;
    	
    	Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
    	insert invoice;
    	
    	InvoiceItem__c invoiceItem = ULTestData.createInvoiceItem(invoice.Id, product.Id, '394368000010', 10);
    	insert invoiceItem;
    	
    	Case case1 = ULTestData.createCase(mapRecType.get('Reposicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aguardando nota fiscal de devolução', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	case1.Status = 'Aberto';
    	insert case1;
    	
    	// Start Test
		System.Test.startTest();
		
    	Order__c order1 = ULTestData.createOrder(account.Id, accountAreaSales.Id, '9998713');
    	order1.CaseLkp__c = case1.Id;
    	order1.OrderStatusTxt__c = 'Processado completamente';
    	order1.OrderTypeTxt__c = 'ZDOP';
    	insert order1;
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(order1 != null);
    }
    
    static testMethod void testOrderReposicao_StatusNaoCancelada()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
    	Seller__c seller = ULTestData.createSeller('John Doe', '1000');
    	insert seller;
    	
    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	insert account;    	
    	
    	AccountAreaSales__c accountAreaSales = ULTestData.createAccountAreaSales(account.Id, seller.Id, '999333AM01RVPR00009090');
    	insert accountAreaSales;
    	
    	Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
    	insert contact;
    	
    	Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
    	insert carrier;
    	
    	Product2 product = ULTestData.createProduct('FITA VIDEO', '900000000000001010');
    	insert product;
    	
    	Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
    	insert invoice;
    	
    	InvoiceItem__c invoiceItem = ULTestData.createInvoiceItem(invoice.Id, product.Id, '394368000010', 10);
    	insert invoiceItem;
    	
    	Case case1 = ULTestData.createCase(mapRecType.get('Reposicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aguardando nota fiscal de devolução', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	insert case1;
    	
    	case1.Status = 'Aguardando amostra';
    	update case1;
    	
    	// Start Test
		System.Test.startTest();
		
    	Order__c order1 = ULTestData.createOrder(account.Id, accountAreaSales.Id, '9998713');
    	order1.CaseLkp__c = case1.Id;
    	order1.OrderStatusTxt__c = 'xpto';
    	order1.OrderTypeTxt__c = 'ZDOP';
    	insert order1;
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(order1 != null);
    }
    
    static testMethod void testOrderReposicao_StatusCancelada()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
    	Seller__c seller = ULTestData.createSeller('John Doe', '1000');
    	insert seller;
    	
    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	insert account;    	
    	
    	AccountAreaSales__c accountAreaSales = ULTestData.createAccountAreaSales(account.Id, seller.Id, '999333AM01RVPR00009090');
    	insert accountAreaSales;
    	
    	Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
    	insert contact;
    	
    	Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
    	insert carrier;
    	
    	Product2 product = ULTestData.createProduct('FITA VIDEO', '900000000000001010');
    	insert product;
    	
    	Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
    	insert invoice;
    	
    	InvoiceItem__c invoiceItem = ULTestData.createInvoiceItem(invoice.Id, product.Id, '394368000010', 10);
    	insert invoiceItem;
    	
    	Case case1 = ULTestData.createCase(mapRecType.get('Reposicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aguardando nota fiscal de devolução', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	insert case1;
    	
    	// Start Test
		System.Test.startTest();
		
    	Order__c order1 = ULTestData.createOrder(account.Id, accountAreaSales.Id, '9998713');
    	order1.CaseLkp__c = case1.Id;
    	order1.OrderStatusTxt__c = 'Cancelada';
    	order1.OrderTypeTxt__c = 'ZDOP';
    	insert order1;
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(order1 != null);
    }
    
    static testMethod void testOrderExtravioNotaFiscal_StatusNaoCancelada()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
    	Seller__c seller = ULTestData.createSeller('John Doe', '1000');
    	insert seller;
    	
    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	insert account;    	
    	
    	AccountAreaSales__c accountAreaSales = ULTestData.createAccountAreaSales(account.Id, seller.Id, '999333AM01RVPR00009090');
    	insert accountAreaSales;
    	
    	Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
    	insert contact;
    	
    	Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
    	insert carrier;
    	
    	Product2 product = ULTestData.createProduct('FITA VIDEO', '900000000000001010');
    	insert product;
    	
    	Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
    	insert invoice;
    	
    	InvoiceItem__c invoiceItem = ULTestData.createInvoiceItem(invoice.Id, product.Id, '394368000010', 10);
    	insert invoiceItem;
    	
    	Case case1 = ULTestData.createCase(mapRecType.get('ExtravioNotaFiscal'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aguardando nota fiscal de devolução', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	insert case1;
    	
    	case1.Status = 'Aguardando amostra';
    	update case1;
    	
    	// Start Test
		System.Test.startTest();
		
    	Order__c order1 = ULTestData.createOrder(account.Id, accountAreaSales.Id, '9998713');
    	order1.CaseLkp__c = case1.Id;
    	order1.OrderStatusTxt__c = 'xpto';
    	order1.OrderTypeTxt__c = 'ZDOP';

		try {
    		insert order1;
		}
    	catch (Exception ex) {}
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(order1 != null);
    }
    
    static testMethod void testOrderSinistro_StatusNaoCanceladaParcial()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
    	Seller__c seller = ULTestData.createSeller('John Doe', '1000');
    	insert seller;
    	
    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	insert account;    	
    	
    	AccountAreaSales__c accountAreaSales = ULTestData.createAccountAreaSales(account.Id, seller.Id, '999333AM01RVPR00009090');
    	insert accountAreaSales;
    	
    	Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
    	insert contact;
    	
    	Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
    	insert carrier;
    	
    	Product2 product = ULTestData.createProduct('FITA VIDEO', '900000000000001010');
    	insert product;
    	
    	Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
    	insert invoice;
    	
    	InvoiceItem__c invoiceItem = ULTestData.createInvoiceItem(invoice.Id, product.Id, '394368000010', 10);
    	insert invoiceItem;
    	
    	Case case1 = ULTestData.createCase(mapRecType.get('Sinistro'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aguardando nota fiscal de devolução', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	case1.SinisterTxt__c = 'Total';
    	insert case1;
    	
    	case1.Status = 'Aguardando amostra';
    	update case1;
    	
    	// Start Test
		System.Test.startTest();
		
    	Order__c order1 = ULTestData.createOrder(account.Id, accountAreaSales.Id, '9998713');
    	order1.CaseLkp__c = case1.Id;
    	order1.OrderStatusTxt__c = 'xpto';
    	order1.OrderTypeTxt__c = 'ZDOP';
    	insert order1;
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(order1 != null);
    }
    
    static testMethod void testOrderSinistro_StatusNaoCanceladaTotal()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
    	Seller__c seller = ULTestData.createSeller('John Doe', '1000');
    	insert seller;
    	
    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	insert account;    	
    	
    	AccountAreaSales__c accountAreaSales = ULTestData.createAccountAreaSales(account.Id, seller.Id, '999333AM01RVPR00009090');
    	insert accountAreaSales;
    	
    	Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
    	insert contact;
    	
    	Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
    	insert carrier;
    	
    	Product2 product = ULTestData.createProduct('FITA VIDEO', '900000000000001010');
    	insert product;
    	
    	Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
    	insert invoice;
    	
    	InvoiceItem__c invoiceItem = ULTestData.createInvoiceItem(invoice.Id, product.Id, '394368000010', 10);
    	insert invoiceItem;
    	
    	Case case1 = ULTestData.createCase(mapRecType.get('Sinistro'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aguardando nota fiscal de devolução', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	case1.SinisterTxt__c = 'Parcial';
    	insert case1;
    	
    	case1.Status = 'Aguardando amostra';
    	update case1;
    	
    	// Start Test
		System.Test.startTest();
		
    	Order__c order1 = ULTestData.createOrder(account.Id, accountAreaSales.Id, '9998713');
    	order1.CaseLkp__c = case1.Id;
    	order1.OrderStatusTxt__c = 'xpto';
    	order1.OrderTypeTxt__c = 'ZDOP';
    	insert order1;
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(order1 != null);
    }
    
    static testMethod void testOrderReclamacao_StatusNaoCancelada()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
    	Seller__c seller = ULTestData.createSeller('John Doe', '1000');
    	insert seller;
    	
    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	insert account;    	
    	
    	AccountAreaSales__c accountAreaSales = ULTestData.createAccountAreaSales(account.Id, seller.Id, '999333AM01RVPR00009090');
    	insert accountAreaSales;
    	
    	Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
    	insert contact;
    	
    	Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
    	insert carrier;
    	
    	Product2 product = ULTestData.createProduct('FITA VIDEO', '900000000000001010');
    	insert product;
    	
    	Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
    	insert invoice;
    	
    	InvoiceItem__c invoiceItem = ULTestData.createInvoiceItem(invoice.Id, product.Id, '394368000010', 10);
    	insert invoiceItem;
    	
    	Case case1 = ULTestData.createCase(mapRecType.get('Reclamacao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aguardando nota fiscal de devolução', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	insert case1;
    	
    	case1.Status = 'Aguardando amostra';
    	update case1;
    	
    	// Start Test
		System.Test.startTest();
		
    	Order__c order1 = ULTestData.createOrder(account.Id, accountAreaSales.Id, '9998713');
    	order1.CaseLkp__c = case1.Id;
    	order1.OrderStatusTxt__c = 'xpto';
    	order1.OrderTypeTxt__c = 'ZDOP';
    	insert order1;
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(order1 != null);
    }
    
    static testMethod void testOrderDevolucao_StatusNaoCancelada()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
    	Seller__c seller = ULTestData.createSeller('John Doe', '1000');
    	insert seller;
    	
    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	insert account;    	
    	
    	AccountAreaSales__c accountAreaSales = ULTestData.createAccountAreaSales(account.Id, seller.Id, '999333AM01RVPR00009090');
    	insert accountAreaSales;
    	
    	Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
    	insert contact;
    	
    	Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
    	insert carrier;
    	
    	Product2 product = ULTestData.createProduct('FITA VIDEO', '900000000000001010');
    	insert product;
    	
    	Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
    	insert invoice;
    	
    	InvoiceItem__c invoiceItem = ULTestData.createInvoiceItem(invoice.Id, product.Id, '394368000010', 10);
    	insert invoiceItem;
    	
    	Case case1 = ULTestData.createCase(mapRecType.get('Devolucao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aguardando nota fiscal de devolução', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');

		try {
    		insert case1;
		}
		catch (Exception ex) {}
    	
    	// Start Test
		System.Test.startTest();
		
    	Order__c order1 = ULTestData.createOrder(account.Id, accountAreaSales.Id, '9998713');
    	order1.CaseLkp__c = case1.Id;
    	order1.OrderStatusTxt__c = 'xpto';
    	order1.OrderTypeTxt__c = 'ZDOP';
    	insert order1;
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(order1 != null);
    }
    
    static testMethod void testOrderProdutoTrocado_StatusNaoCancelada()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
    	Seller__c seller = ULTestData.createSeller('John Doe', '1000');
    	insert seller;
    	
    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	insert account;    	
    	
    	AccountAreaSales__c accountAreaSales = ULTestData.createAccountAreaSales(account.Id, seller.Id, '999333AM01RVPR00009090');
    	insert accountAreaSales;
    	
    	Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
    	insert contact;
    	
    	Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
    	insert carrier;
    	
    	Product2 product = ULTestData.createProduct('FITA VIDEO', '900000000000001010');
    	insert product;
    	
    	Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
    	insert invoice;
    	
    	InvoiceItem__c invoiceItem = ULTestData.createInvoiceItem(invoice.Id, product.Id, '394368000010', 10);
    	insert invoiceItem;
    	
    	Case case1 = ULTestData.createCase(mapRecType.get('ProdutoTrocado'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aguardando nota fiscal de devolução', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	case1.Type = 'Quantidades iguais';

		try {
    		insert case1;
		}
		catch (Exception ex) {}
		
    	// Start Test
		System.Test.startTest();
		
    	Order__c order1 = ULTestData.createOrder(account.Id, accountAreaSales.Id, '9998713');
    	order1.CaseLkp__c = case1.Id;
    	order1.OrderStatusTxt__c = 'xpto';
    	order1.OrderTypeTxt__c = 'ZDOP';
    	insert order1;
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(order1 != null);
    }
}