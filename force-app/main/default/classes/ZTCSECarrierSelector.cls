@isTest
private class ZTCSECarrierSelector
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
    	
    	// Start Test
		System.Test.startTest();
		
		List<Carrier__c> test1 = new CSECarrierSelector().selectById(new Set<Id>{carrier.Id});
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(test1 != null);
    }
}