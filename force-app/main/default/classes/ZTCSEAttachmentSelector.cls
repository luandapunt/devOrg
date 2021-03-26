@isTest
private class ZTCSEAttachmentSelector
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
    	
    	Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
    	insert invoice;
    	
    	Case aCase = ULTestData.createCase(mapRecType.get('Substituicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	insert aCase;
    	
    	Attachment att = ULTestData.createAttachment(aCase.Id);
    	insert att;
    	
    	// Start Test
		System.Test.startTest();
		
    	List<Attachment> test1 = new CSEAttachmentSelector().selectById(new Set<Id>{att.Id});
    	
    	List<Attachment> test2 = new CSEAttachmentSelector().selectByCase(new Set<Id>{aCase.Id});
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(test1 != null);
		System.assert(test2 != null);
    }
}