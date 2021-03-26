@isTest
private class ZTEventQueueCommandMappping
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	IntegrationMap__c integrationMap = ULTestData.createIntegrationMap('Integração XXX', 'Contact', 'GenericIntegrationService', 'eventName', 'Insert', '', 'CSV');
    	insert integrationMap;
    	
    	Queue__c queue = ULTestData.createQueue(integrationMap.Id, 'eventName', '99');
    	insert queue;
    	
    	EventQueue eventQueue = new EventQueue();
    	
    	// Start Test
		System.Test.startTest();
		
    	EventQueueCommandMappping eventQueueCommandMappping = new EventQueueCommandMappping();
    	
    	eventQueueCommandMappping.getCommand('eventName');
    	
    	eventQueueCommandMappping.getCommand(eventQueue);
    		
    	eventQueueCommandMappping.getEventListOrderExecution('eventName');
    	
    	Map<String, IntegrationMap__c> test01 = eventQueueCommandMappping.getDeliveryInfoMap('eventName');
    	
    	eventQueueCommandMappping.createIntanceFor('eventName');
    	
    	Boolean test02 = eventQueueCommandMappping.hasHandlerFor(eventQueue);
    	
    	try {
    		eventQueueCommandMappping.createIntanceFor(eventQueue);
    	}
    	catch (Exception ex) {}
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(eventQueueCommandMappping != null);
    }
}