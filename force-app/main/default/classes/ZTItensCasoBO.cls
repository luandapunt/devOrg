@isTest
private class ZTItensCasoBO
{
    static testMethod void testReposicaoItem()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
		RecordType recordType = [Select Id from RecordType where DeveloperName = 'BusinessAccountSAC' and SobjectType = 'Account'];
    	
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
    	
    	Case case1 = ULTestData.createCase(mapRecType.get('Reposicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	insert case1;
    	
    	// Start Test
		System.Test.startTest();
		
    	ItensCasoBO itensCasoBO = new ItensCasoBO(case1.Id);
    	
    	// call getters
    	String var01 = itensCasoBO.Comments;
    	String var02 = itensCasoBO.QualityProblem;
    	
    	// call methods
    	Boolean test01 = itensCasoBO.isReclamacao();
		Boolean test02 = itensCasoBO.isSubstituicao();
    	Boolean test03 = itensCasoBO.canEditProduct();
    	Boolean test04 = itensCasoBO.getShowProdutoTrocado();
    	Boolean test05 = itensCasoBO.getShowComments();
    	Boolean test06 = itensCasoBO.getShowQualityProblem();
    	List<SelectOption> test07 = itensCasoBO.getFailureOptions();
    	List<CaseItemVO> test08 = itensCasoBO.loadCaseItemVO(case1.Id); 
    	
    	// Stop Test
		System.Test.stopTest();
    }
    
    static testMethod void testReposicaoVolume()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
		RecordType recordType = [Select Id from RecordType where DeveloperName = 'BusinessAccountSAC' and SobjectType = 'Account'];
    	
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
    	
    	Case case1 = ULTestData.createCase(mapRecType.get('Reposicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Volume', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	case1.NotSendemailBln__c = true;
    	insert case1;
    	
    	// Start Test
		System.Test.startTest();
		
    	ItensCasoBO itensCasoBO = new ItensCasoBO(case1.Id);
    	
    	// call getters
    	String var01 = itensCasoBO.Comments;
    	String var02 = itensCasoBO.QualityProblem;
    	
    	// call methods
    	Boolean test01 = itensCasoBO.isReclamacao();
		Boolean test02 = itensCasoBO.isSubstituicao();
    	Boolean test03 = itensCasoBO.canEditProduct();
    	Boolean test04 = itensCasoBO.getShowProdutoTrocado();
    	Boolean test05 = itensCasoBO.getShowComments();
    	Boolean test06 = itensCasoBO.getShowQualityProblem();
    	List<SelectOption> test07 = itensCasoBO.getFailureOptions();
    	List<CaseItemVO> test08 = itensCasoBO.loadCaseItemVO(case1.Id); 
    	
    	// Stop Test
		System.Test.stopTest();
    }
    
    static testMethod void testReposicaoOutro()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
		RecordType recordType = [Select Id from RecordType where DeveloperName = 'BusinessAccountSAC' and SobjectType = 'Account'];
    	
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
    	
    	Case case1 = ULTestData.createCase(mapRecType.get('Reposicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Outro', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	insert case1;
    	
    	// Start Test
		System.Test.startTest();
		
    	ItensCasoBO itensCasoBO = new ItensCasoBO(case1.Id);
    	
    	// call getters
    	String var01 = itensCasoBO.Comments;
    	String var02 = itensCasoBO.QualityProblem;
    	
    	// call methods
    	Boolean test01 = itensCasoBO.isReclamacao();
		Boolean test02 = itensCasoBO.isSubstituicao();
    	Boolean test03 = itensCasoBO.canEditProduct();
    	Boolean test04 = itensCasoBO.getShowProdutoTrocado();
    	Boolean test05 = itensCasoBO.getShowComments();
    	Boolean test06 = itensCasoBO.getShowQualityProblem();
    	List<SelectOption> test07 = itensCasoBO.getFailureOptions();
    	List<CaseItemVO> test08 = itensCasoBO.loadCaseItemVO(case1.Id); 
    	
    	// Stop Test
		System.Test.stopTest();
    }
    
    static testMethod void testDevolucao()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
		RecordType recordType = [Select Id from RecordType where DeveloperName = 'BusinessAccountSAC' and SobjectType = 'Account'];
    	
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
    	
    	Case case1 = ULTestData.createCase(mapRecType.get('Devolucao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	system.debug(case1.AccountId);
        insert case1;
    	
    	// Start Test
		System.Test.startTest();
		
    	ItensCasoBO itensCasoBO = new ItensCasoBO(case1.Id);
    	
    	// call getters
    	String var01 = itensCasoBO.Comments;
    	String var02 = itensCasoBO.QualityProblem;
    	
    	// call methods
    	Boolean test01 = itensCasoBO.isReclamacao();
		Boolean test02 = itensCasoBO.isSubstituicao();
    	Boolean test03 = itensCasoBO.canEditProduct();
    	Boolean test04 = itensCasoBO.getShowProdutoTrocado();
    	Boolean test05 = itensCasoBO.getShowComments();
    	Boolean test06 = itensCasoBO.getShowQualityProblem();
    	List<SelectOption> test07 = itensCasoBO.getFailureOptions();
    	List<CaseItemVO> test08 = itensCasoBO.loadCaseItemVO(case1.Id); 
    	
    	// Stop Test
		System.Test.stopTest();
    }
	
	static testMethod void testSubstituicao()
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
		
    	ItensCasoBO itensCasoBO = new ItensCasoBO(case1.Id);
    	
    	// call getters
    	String var01 = itensCasoBO.Comments;
    	String var02 = itensCasoBO.QualityProblem;
    	
    	// call methods
    	Boolean test01 = itensCasoBO.isReclamacao();
		Boolean test02 = itensCasoBO.isSubstituicao();
    	Boolean test03 = itensCasoBO.canEditProduct();
    	Boolean test04 = itensCasoBO.getShowProdutoTrocado();
    	Boolean test05 = itensCasoBO.getShowComments();
    	Boolean test06 = itensCasoBO.getShowQualityProblem();
    	List<SelectOption> test07 = itensCasoBO.getFailureOptions();
    	List<CaseItemVO> test08 = itensCasoBO.loadCaseItemVO(case1.Id); 
    	
    	// Stop Test
		System.Test.stopTest();
    }
    
    static testMethod void testReclamacaoWithItem()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
		RecordType recordType = [Select Id from RecordType where DeveloperName = 'BusinessAccountSAC' and SobjectType = 'Account'];
    	
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
    	
    	Case case1 = ULTestData.createCase(mapRecType.get('Reclamacao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	insert case1;
    	
    	CaseItem__c caseItem1 = ULTestData.createCaseItem(case1.Id, '999550000037unAAAQ01t55000000JhBjAAK', 'failureType', 'comments', 'qualityProblem');
    	insert caseItem1;
    	
    	// Start Test
		System.Test.startTest();
		
    	ItensCasoBO itensCasoBO = new ItensCasoBO(case1.Id);
    	
    	// call getters
    	String var01 = itensCasoBO.Comments;
    	String var02 = itensCasoBO.QualityProblem;
    	
    	// call methods
    	Boolean test01 = itensCasoBO.isReclamacao();
		Boolean test02 = itensCasoBO.isSubstituicao();
    	Boolean test03 = itensCasoBO.canEditProduct();
    	Boolean test04 = itensCasoBO.getShowProdutoTrocado();
    	Boolean test05 = itensCasoBO.getShowComments();
    	Boolean test06 = itensCasoBO.getShowQualityProblem();
    	List<SelectOption> test07 = itensCasoBO.getFailureOptions();
    	List<CaseItemVO> test08 = itensCasoBO.loadCaseItemVO(case1.Id); 
    	
    	// Stop Test
		System.Test.stopTest();
    }
    
    static testMethod void testReclamacaoWithoutItem()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
		RecordType recordType = [Select Id from RecordType where DeveloperName = 'BusinessAccountSAC' and SobjectType = 'Account'];
    	
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
    	
    	Case case1 = ULTestData.createCase(mapRecType.get('Reclamacao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	insert case1;
    	
    	// Start Test
		System.Test.startTest();
		
    	ItensCasoBO itensCasoBO = new ItensCasoBO(case1.Id);
    	
    	// call getters
    	String var01 = itensCasoBO.Comments;
    	String var02 = itensCasoBO.QualityProblem;
    	
    	// call methods
    	Boolean test01 = itensCasoBO.isReclamacao();
		Boolean test02 = itensCasoBO.isSubstituicao();
    	Boolean test03 = itensCasoBO.canEditProduct();
    	Boolean test04 = itensCasoBO.getShowProdutoTrocado();
    	Boolean test05 = itensCasoBO.getShowComments();
    	Boolean test06 = itensCasoBO.getShowQualityProblem();
    	List<SelectOption> test07 = itensCasoBO.getFailureOptions();
    	List<CaseItemVO> test08 = itensCasoBO.loadCaseItemVO(case1.Id); 
    	
    	// Stop Test
		System.Test.stopTest();
    }
}