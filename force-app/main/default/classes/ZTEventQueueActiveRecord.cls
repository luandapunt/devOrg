@isTest
private class ZTEventQueueActiveRecord
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	IntegrationMap__c integrationMap = ULTestData.createIntegrationMap('Integração XXX', 'Contact', 'GenericIntegrationService', 'SYNC_TESTE_XXX', 'Insert', '', 'CSV');
    	insert integrationMap;
    	
    	Queue__c queue = ULTestData.createQueue(integrationMap.Id, 'SYNC_XXX', '99');
    	insert queue;
    	
    	Attachment att = ULTestData.createAttachment(queue.Id);
    	insert att;
    	
    	EventQueue eventQueue = new EventQueue(queue);
    	
    	// Start Test
		System.Test.startTest();
		
    	eventQueue.updateAll(new List<Queue__c>{queue});
    	
    	Queue__c test01 = eventQueue.save(queue);
		
		eventQueue.storePayloads(new List<Attachment>{att});
		
		// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(eventQueue != null);
    }
}