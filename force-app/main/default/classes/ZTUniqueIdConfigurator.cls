@isTest
private class ZTUniqueIdConfigurator
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
    	
    	Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
    	insert invoice;
    	
    	Case aCase = ULTestData.createCase(mapRecType.get('Substituicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Elogio', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	insert aCase;
    	
    	// Start Test
		System.Test.startTest();
		
    	UniqueIdConfigurator con = new UniqueIdConfigurator();
    	con.configure(Case.CustomIdTxt__c, new List<SObject>{aCase}, new List<Schema.SObjectField>{Case.CustomIdTxt__c});
    	
    	// Stop Test
		System.Test.stopTest();
    }
}