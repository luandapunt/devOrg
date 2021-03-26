public with sharing class EventQueueCommandMappping {
	
	public Map<String, IntegrationMap__c> integrationMap {get;set;}
	
	public EventQueueCommandMappping (){
		this.integrationMap = new Map<String, IntegrationMap__c>();
		
		List<IntegrationMap__c> integrationMapList = new List<IntegrationMap__c>();
		integrationMapList = IntegrationMapDAO.getAll();
		
		for (IntegrationMap__c record : integrationMapList) {
			this.integrationMap.put(record.IntegrationId__c, record);
		}
		
	}
		
	public IIntegrationService getCommand(String eventName) {
		if (!hasHandlerFor(eventName)) return new UnHandledIntegration();  
		return createIntanceFor(eventName);
	} 
	
	//to delete
	public IIntegrationService getCommand(EventQueue eventName) {
		if (!hasHandlerFor(eventName)) return new UnHandledIntegration();  
		return createIntanceFor(eventName);
	} 
		
		
	public Boolean hasHandlerFor (String eventName) {
		return this.integrationMap.containsKey(eventName);
	}	
	
	//to delete
	public Boolean hasHandlerFor (EventQueue event) {
		return this.integrationMap.containsKey(event.getEventName());
	}	
	
	public IntegrationMap__c getDeliveryInfoFor(String eventName)  {
		return integrationMap.get(eventName);		
	}
	
	/*
		Determine execution of event execution
		Eg.
			1 - Invoice
				2 - Invoice Item
				3 - another Child Item
	*/
	public List<String> getEventListOrderExecution(String eventName) {

		List<String> eventList = new List<String>();

		IntegrationMap__c intMap = integrationMap.get(eventName);
		
		//first add the main event
		eventList.add(eventName);
		
		//and add child integrations
		for (IntegrationMapChild__c child : intMap.IntegratioMapParents__r) {
			eventList.add(child.ChildLkp__r.IntegrationId__c);
		}
		
		return eventList;
		
	}

	public Map<String, IntegrationMap__c> getDeliveryInfoMap(String eventName)  {
		return integrationMap;
	}
	
	//to delete
	public IIntegrationService createIntanceFor (EventQueue event) {
		IntegrationMap__c integrationInfo = getDeliveryInfoFor(event.getEventName());	
		event.deliveryInfo = integrationInfo;
		Type commandType = Type.forName(integrationInfo.CommandClassName__c);
		IIntegrationService integrationService = (IIntegrationService) commandType.newInstance();
		return integrationService;
	}
	
	public IIntegrationService createIntanceFor (String eventName) {
		IntegrationMap__c integrationInfo = getDeliveryInfoFor(eventName);	
		//event.deliveryInfo = integrationInfo;
		Type commandType = Type.forName(integrationInfo.CommandClassName__c);
		IIntegrationService integrationService = (IIntegrationService) commandType.newInstance();
		return integrationService;
	}

}