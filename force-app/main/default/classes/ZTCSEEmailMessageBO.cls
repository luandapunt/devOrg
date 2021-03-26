@isTest
private class ZTCSEEmailMessageBO
{
    static testMethod void testAll()
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
    	
    	Case caseReposicao = ULTestData.createCase(mapRecType.get('Reposicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aguardando retorno transportadora', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	//Case caseConsultaPedido = ULTestData.createCase(mapRecType.get('ConsultaPedido'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aguardando parecer do setor', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	//Case caseProrrogacao = ULTestData.createCase(mapRecType.get('Prorrogacao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aguardando retorno transportadora', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	insert new List<Case>{caseReposicao /*, caseConsultaPedido,caseProrrogacao*/ };
    	
    	// Start Test
		System.Test.startTest();
		
    	EmailMessage emailMessageReposicao = ULTestData.createEmailMessage(caseReposicao.Id, '2');
    	insert emailMessageReposicao;
    	
    	//EmailMessage emailMessageConsultaPedido = ULTestData.createEmailMessage(caseConsultaPedido.Id, '2');
    	//insert emailMessageConsultaPedido;
    	
    	//EmailMessage emailMessageProrrogacao = ULTestData.createEmailMessage(caseProrrogacao.Id, '2');
    	//insert emailMessageProrrogacao;
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		//System.assert(lstAccountAddress != null);
    }
}