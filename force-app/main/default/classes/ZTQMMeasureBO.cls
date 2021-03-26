@isTest
private class ZTQMMeasureBO {
    static testMethod void testeAll() {
    	
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case', 'QM__c'});
    	
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
    	
    	QM__c qm = ULTestData.createQM(mapRecType.get('QMReclamacao'), case1.Id);
    	qm.SalesforceQMTxt__c = '99001';
    	insert qm;
    	
    	System.Test.startTest();
    	
    	QMMeasure__c qmMeasure = new QMMeasure__c(QMSalesforceMdt__c = qm.Id, QMSAPTxt__c = '00125455', Name = '1235', CaseLkp__c = case1.Id, StatusTxt__c = 'Aberto', UserFullNameTxt__c = 'nome', CustomIDTxt__c = '4654', QMLineNmb__c = 3);
    	insert qmMeasure;
    	
    	System.Test.stopTest();
    }
}