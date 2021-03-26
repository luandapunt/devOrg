@isTest
private class ZTCaseMotiveCtrl
{
	static testMethod void testCreateCaseInvoiceAndOrderV1()
	{
		// Prepare test data
		Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});

    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	insert account;
    	
    	Entitlement entitlement = ULTestData.createEntitlement(account.Id, 'Name');
    	insert entitlement;
    	
    	Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
    	insert contact;
    	
    	Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
    	insert carrier;
    	
    	Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
    	insert invoice;
    	
    	Case aCase = ULTestData.createCase(mapRecType.get('Substituicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	insert aCase;
		
		/*
		*	String name, String profileName, String caseType, String nature, String caseCategory, String contact
		*/
		CaseMotive__c caseMotive = ULTestData.createCaseMotive('Cliente Incorreto', 'Administrador do sistema;Analista SAC;Coordenador SAC', 'Devolução', 'Reclamação', 'Produto', 'Cliente');
		insert caseMotive;
		
		List<ApexRedirectMap__c> redirectMapList = new List<ApexRedirectMap__c>();
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'CaseList', UrlSufix__c = '/500/o'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'CreateCase', UrlSufix__c = '/500/e?retURL=%2F500%2Fo'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'InvoiceName', UrlSufix__c = 'CF00N55000000iEy3'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'OrderName', UrlSufix__c = 'CF00N55000000iGoF'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'OrderLkpCase', UrlSufix__c = '00N55000000iGoF_lkid'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'InvoiceLkpCase', UrlSufix__c = 'CF00N55000000iEy3_lkid'));
    	
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'ContactCase', UrlSufix__c = 'cas11'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'CoordinatorEmailCase', UrlSufix__c = '00N55000000iZtE'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'SellerNameCase', UrlSufix__c = 'CF00N55000000iGXn'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'CategoryCase', UrlSufix__c = '00N55000000ibw0'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'CarrierLkpCase', UrlSufix__c = 'CF00N55000000iGXi_lkid'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'CarrierNameCase', UrlSufix__c = 'CF00N55000000iGXi'));
    	
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'SellerEmail', UrlSufix__c = '00N55000000iNsO'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'CarrierEmail', UrlSufix__c = '00N55000000iNvc'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'ReasonCase', UrlSufix__c = 'cas6'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'ManagerEmailCase', UrlSufix__c = '00N55000000iZzv'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'SellerLkpCase', UrlSufix__c = 'C00N55000000iGXn_lkid'));
    	redirectMapList.add(new ApexRedirectMap__c(Name = 'NatureCase', UrlSufix__c = '00N55000000ibvv'));
    	insert redirectMapList;
		
		// Start Test
		System.Test.startTest();
		
		ApexPages.StandardController std = new ApexPages.StandardController(aCase);
		Apexpages.currentPage().getParameters().put('inConsole', 'yes');
		Apexpages.currentPage().getParameters().put('accountId', account.Id);
		
		// create controller
    	CaseMotiveCtrl ctrl = new CaseMotiveCtrl(std);
    	
    	// call methods
    	try {
    		ctrl.setRecordTypeList();   // error in selectedCaseMotive, not initialized
    	} catch (Exception ex) {}
    	
    	try {
    		ctrl.doNext();            // error in selectedCaseMotive, not initialized
    	} catch (Exception ex) {}
    	
    	ctrl.doCancel();
    	
    	// Stop Test
		System.Test.stopTest();
	}
	
	static testMethod void testCreateCaseInvoiceAndOrderV2()
	{
		// Prepare test data
		Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
		Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	insert account;    	
    	
    	Entitlement entitlement = ULTestData.createEntitlement(account.Id, 'Name');
    	insert entitlement;
    	
    	Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
    	insert contact;
    	
    	Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
    	insert carrier;
    	
    	Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
    	insert invoice;
    	
    	Case aCase = ULTestData.createCase(mapRecType.get('Substituicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	insert aCase;
		
		CaseMotive__c caseMotive = ULTestData.createCaseMotive('Cliente Incorreto', 'Administrador do sistema;Analista SAC;Coordenador SAC', 'Devolução', 'Reclamação', 'Produto', 'Cliente');
		insert caseMotive;
		
		ApexRedirectMap__c apexRedirectMap = ULTestData.createApexRedirectMap('CaseList', '/500/o');
		insert apexRedirectMap;
		
		// Start Test
		System.Test.startTest();
		
		ApexPages.StandardController std = new ApexPages.StandardController(aCase);
		Apexpages.currentPage().getParameters().put('inConsole', 'no');
		
    	// create controller
    	CaseMotiveCtrl ctrl = new CaseMotiveCtrl(std);
    	ctrl.selectedContact = 'Cliente';
    	ctrl.setNatureList();
    	
    	ctrl.selectedNature = 'Reclamação';
    	ctrl.setCategoryList();
    	
    	ctrl.selectedCategory = 'Produto';
    	ctrl.setMotiveList();
    	
    	ctrl.selectedCaseMotive = 'Não aquece';
    	ctrl.setRecordTypeList();
    	
    	ctrl.selectedRecordType = 'Devolução';
    	
    	ctrl.selectedRecordType = '--Nenhum--';
    	
    	ctrl.selectedCaseMotive = '--Nenhum--';
    	ctrl.setRecordTypeList();
    	
    	ctrl.selectedCategory = '--Nenhum--';
    	ctrl.setMotiveList();
    	
    	ctrl.selectedNature = '--Nenhum--';
    	ctrl.setCategoryList();
    	
    	ctrl.selectedContact = '--Nenhum--';
    	ctrl.setNatureList();
    	
    	// call methods
    	ctrl.doCancel();
    	
    	// Stop Test
		System.Test.stopTest();
	}
}