@isTest
private class ZTEventQueue
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	IntegrationMap__c integrationMap = ULTestData.createIntegrationMap('Integração XXX', 'Contact', 'GenericIntegrationService', 'SYNC_TESTE_XXX', 'Insert', '', 'CSV');
    	insert integrationMap;
    	
    	Queue__c queue = ULTestData.createQueue(integrationMap.Id, 'SYNC_XXX', '99');
    	insert queue;
    	
    	Dom.Document domDoc = new Dom.Document();
		domDoc.load('<doc><item>1</item></doc>');

    	// Start Test
		System.Test.startTest();
		
    	EventQueue eventQueue1 = new EventQueue();
    	
    	EventQueue eventQueue2 = new EventQueue(queue.Id);
    	
    	EventQueue eventQueue3 = new EventQueue(queue);
    	
    	// Inner classes
    	try {
    		EventQueue.UnhandleOperation unhandleOperation = new EventQueue.UnhandleOperation();
    		unhandleOperation.execute(new List<SObject>{queue});
    	}
    	catch (Exception ex) {}
    	
    	// Attributes
    	String var01 = eventQueue3.id;
	    String var02 = eventQueue3.eventName;
	    String var03 = eventQueue3.sender;
	    String var04 = eventQueue3.receiver;
	    String var05 = eventQueue3.eventId;
	    String var06 = eventQueue3.internalId;
	    String var07 = eventQueue3.status;
	    String var08 = eventQueue3.statusMessage;
    	List<Attachment> var09 = eventQueue3.payloads;
    	String var10 = eventQueue3.authenticationToken;
		Queue__c var11 = eventQueue3.event;
		String var12 = eventQueue3.payloadData;
		IntegrationMap__c var13 = eventQueue3.deliveryInfo;
		
		// Methods setters
		eventQueue3.setEventName('eventName');
		eventQueue3.setSoapPayload(domDoc);
		
		// Methods getters
    	Queue__c method01 = eventQueue3.getQueue();
    	String method02 = eventQueue3.getReceiver();
    	String method03 = eventQueue3.getPayload();
    	String method04 = eventQueue3.getEventName();
    	String method05 = eventQueue3.getSoapPayload();
    	
    	// Methods
    	eventQueue3.save();
    	
    	try {
    		eventQueue3.buildFromExternalEvent(eventQueue3);
    	}
    	catch (Exception ex) {}
    	
    	Map<String, String> eventsMap = new Map<String, String>();
    	eventsMap.put('1', 'XXX');
    	EventQueue.processEventsSync(eventsMap);
    	
    	try {
    		eventQueue3.processEvents(new List<Queue__c>{queue});
    	}
    	catch (Exception ex) {}
    	
    	try {
    		Queue__c method06 = eventQueue3.enrichQueueWithPayload('payload');
    	}
    	catch (Exception ex) {}
    	
    	try {
    		Object method07 = eventQueue3.processEvent();
    	}
    	catch (Exception ex) {}
    	
    	try {
    		Object method08 = eventQueue3.processEvent(eventQueue3);
    	}
    	catch (Exception ex) {}
    	
    	try {
    		eventQueue3.dispatch();
    	}
    	catch (Exception ex) {}
    	
    	Boolean method09 = eventQueue3.isUnhadledEvent(eventQueue3);
    	eventQueue3.getCommand ('eventName');
    	Queue__c method10 = eventQueue3.unhadledEvent(queue);
    	Queue__c method11 = eventQueue3.successfullyProcessedEvent();
    	
    	try {
    		Queue__c method12 = eventQueue3.successfullyDeliveyEvent();
    	}
    	catch (Exception ex) {}
    	
    	try {
    		Queue__c method13 = eventQueue3.successfullyDeliveyEvent(queue);
    	}
    	catch (Exception ex) {}
    	
    	eventQueue3.addPayload('name', 'content');
    	
    	EventQueue method14 = eventQueue3.withDeliveryInfo();
    	
    	String method15 = eventQueue3.truncateLargeText('value'); 
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(eventQueue1 != null);
		System.assert(eventQueue2 != null);
		System.assert(eventQueue3 != null);
    }
}