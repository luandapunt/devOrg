@isTest
private class ZTItensCasoController
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
		RecordType recordType = [Select Id from RecordType where DeveloperName = 'BusinessAccountSAC' and SobjectType = 'Account'];
    	
    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	insert account;    	
    	
    	Entitlement entitlement = ULTestData.createEntitlement(account.Id, 'Name');
    	insert entitlement;
    	
    	Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
    	insert contact;
    	
    	Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
    	insert carrier;
    	
    	Product2 product = ULTestData.createProduct('FITA VIDEO', '900000000000001010');
    	insert product;
    	
    	Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
    	insert invoice;
    	
    	Case aCase = ULTestData.createCase(mapRecType.get('Reclamacao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	insert aCase;
    	
    	CaseItem__c caseItem1 = ULTestData.createCaseItem(aCase.Id, '999550000037unAAAQ01t55000000JhBjAAK', 'failureType', 'comments', 'qualityProblem');
    	caseItem1.ProductLkp__c = product.Id;
    	insert caseItem1;
    	
    	// Start Test
		System.Test.startTest();
		
    	ApexPages.StandardController std = new ApexPages.StandardController(aCase);
		
		// create controller
    	ItensCasoController ctrl = new ItensCasoController(std);
    	
    	// call methods
    	ctrl.save();
    	ctrl.refresh();
    	ctrl.doBack();
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		//System.assert(lstAccountAddress != null);
    }
}