@isTest
private class ZTCSECaseItemSelector
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	insert account;    	
    	
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
    	
    	// Start Test
		System.Test.startTest();
		
		List<CaseItem__c> test1 = new CSECaseItemSelector().selectById(new Set<Id>{caseItem1.Id});
    	
    	List<CaseItem__c> test2 = new CSECaseItemSelector().selectByCaseId(case1.Id);
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(test1 != null);
		System.assert(test2 != null);
    }
}