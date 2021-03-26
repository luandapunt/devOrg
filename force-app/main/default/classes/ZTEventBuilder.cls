@isTest
private class ZTEventBuilder
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	IntegrationMap__c integrationMap = ULTestData.createIntegrationMap('Integração XXX', 'Contact', 'GenericIntegrationService', 'SYNC_TESTE_XXX', 'Insert', '', 'CSV');
    	insert integrationMap;
    	
    	Queue__c queue = ULTestData.createQueue(integrationMap.Id, 'SYNC_XXX', '99');
    	insert queue;
    	
    	// Start Test
		System.Test.startTest();
		
    	EventBuilder eventBuilder = new EventBuilder();
    	
    	eventBuilder.createEventBaseOn(queue, 'eventName')
    		.createEventFor('eventName')
    		.createOutboundEventFor('eventName')
			.forEvent('eventName')
			.forObjectId(queue.Id)
			.usingRetryStrategy()
			.disablingRetryStrategy()
			.withSender('sender')
			.withReceiver('receiver')
			.withPayload('payload')
			.withInternalID('internalId')
			.withStatus('status')
			.isSync()
			.build();
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(eventBuilder != null);
    }
}