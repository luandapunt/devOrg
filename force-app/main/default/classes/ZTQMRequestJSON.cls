@isTest
private class ZTQMRequestJSON
{
    static testMethod void testQMReclamacao()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case', 'QM__c'});
    	
    	Seller__c seller = ULTestData.createSeller('John Doe', '1000');
    	insert seller;
    	
    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	account.CodeCustomerTxt__c = '999';
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
    	//invoice.RemittanceLkp__c = remittance.Id;
    	insert invoice;
    	
    	InvoiceItem__c invoiceItem = ULTestData.createInvoiceItem(invoice.Id, product.Id, '394368000010', 10);
    	insert invoiceItem;
    	
    	Case case1 = ULTestData.createCase(mapRecType.get('Substituicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	insert case1;
    	
    	CaseItem__c caseItem1 = ULTestData.createCaseItem(case1.Id, '999550000037unAAAQ01t55000000JhBjAAK', 'failureType', 'comments', 'qualityProblem');
    	caseItem1.ProductLkp__c = product.Id;
    	caseItem1.ProductDistributionChannelTxt__c = 'XXX';
    	caseItem1.ProductActivitySectorTxt__c = 'YYY';
    	caseItem1.ProductSalesOfficeTxt__c = 'ZZZ';
    	caseItem1.ProductSalesTeamTxt__c = 'TEAM';
    	caseItem1.ProductSalesOrganizationTxt__c = 'KKK';
    	caseItem1.ManufacturingCenterTxt__c = 'YYY';
    	insert caseItem1;
    	
    	Order__c order1 = ULTestData.createOrder(account.Id, accountAreaSales.Id, '9998713');
    	order1.CaseLkp__c = case1.Id;
    	insert order1;
    	
    	try {
    		Remittance__c remittance = ULTestData.createRemittance('name', order1.Id, '99902888A', Date.today(), Date.today());
    		insert remittance;
    	}
    	catch (Exception ex) {}
    	
    	QM__c qm = ULTestData.createQM(mapRecType.get('QMReclamacao'), case1.Id);
    	qm.InvoiceLkp__c = invoice.Id;
    	qm.AccountIssuerLkp__c = account.Id;
    	qm.CaseItemLkp__c = caseItem1.Id;
    	qm.ComplaintReasonTxt__c = 'one-two';
    	qm.RecordTxt__c = 'Substituição';
    	qm.DevolutionTxt__c = 'xxx';
    	qm.NonConformityTxt__c = 'one-two';
    	qm.OriginTxt__c = 'XXX';
    	qm.PriorityTxt__c = 'one-two';
    	qm.CPFTxt__c = '11122233399';
    	
    	insert qm;
    	qm = QMDAO.getById(new Set<Id>{qm.Id}).get(0);
    	
    	// Start Test
		System.Test.startTest();
		
    	QMRequestJSON json = new QMRequestJSON(qm);
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(json != null);
    }
    
    /*
    static testMethod void testQMNaoReclamacao()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case', 'QM__c'});
    	
    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	insert account;    	
    	
    	Seller__c seller = ULTestData.createSeller('John Doe', '1000');
    	insert seller;
    	
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
    	
    	Case case1 = ULTestData.createCase(mapRecType.get('Substituicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	insert case1;
    	
    	CaseItem__c caseItem1 = ULTestData.createCaseItem(case1.Id, '999550000037unAAAQ01t55000000JhBjAAK', 'failureType', 'comments', 'qualityProblem');
    	caseItem1.ProductLkp__c = product.Id;
    	insert caseItem1;
    	
    	Order__c order1 = ULTestData.createOrder(account.Id, accountAreaSales.Id, '9998713');
    	order1.CodeSalesOrganizationTxt__c = 'XXX';
    	insert order1;
    	
    	QM__c qm = ULTestData.createQM(mapRecType.get('QMProrrocacao'), case1.Id);
    	qm.RecordTxt__c = 'Substituição';
    	qm.NonConformityTxt__c = 'one-two';
    	qm.OriginTxt__c = 'XXX';
    	qm.PriorityTxt__c = 'one-two';
    	qm.CPFTxt__c = '11122233399';
    	qm.ManufacturingCenterTxt__c = 'one-two';
    	qm.ClientOrderLkp__c = order1.Id;
    	
    	insert qm;
    	qm = QMDAO.getById(new Set<Id>{qm.Id}).get(0);
    	
    	// Start Test
		System.Test.startTest();
		
    	QMRequestJSON json = new QMRequestJSON(qm);
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(json != null);
    }
    */
}