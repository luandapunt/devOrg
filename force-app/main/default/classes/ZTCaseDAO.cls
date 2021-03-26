@isTest
private class ZTCaseDAO
{
    static testMethod void testAll()
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
    	
    	// Start Test
		System.Test.startTest();
		
    	List<Case> test1 = CaseDAO.getById(new Set<Id>{aCase.Id});
    	
    	Map<Id, Case> test2 = CaseDAO.selectByIdSet(new Set<Id>{aCase.Id});
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(test1 != null);
		System.assert(test2 != null);
    }
}