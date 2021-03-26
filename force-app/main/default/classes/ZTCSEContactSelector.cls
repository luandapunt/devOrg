@isTest
private class ZTCSEContactSelector
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	insert account;    	
    	
    	Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
    	insert contact;
    	
    	// Start Test
		System.Test.startTest();
		
		List<Contact> test1 = new CSEContactSelector().selectById(new Set<Id>{contact.Id});
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(test1 != null);
    }
}