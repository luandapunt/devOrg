public with sharing class EventBuilder {
	
	private Queue__c event; 
		
    public EventBuilder createEventBaseOn(Queue__c event, String eventName ) {   
    	this.event = event;      
        this.event.eventName__c = eventName;
        this.event.status__c = EventQueueStatusType.LOADING_DATA.name();
        return this; 
    }	
		
    public EventBuilder createEventFor(String eventName) {
        event = new Queue__c();
        return createEventBaseOn (event,eventName); 
    }
	
	public EventBuilder createOutboundEventFor(String eventName) { 
		return createEventFor(eventName); 
	}

	
	public EventBuilder forEvent(String eventName) {
		event.eventName__c = eventName;
		return this;
	} 
	
	
	public EventBuilder forObjectId (String id) {
		event.ObjectId__c = id;
		return this; 		
	}	

	public EventBuilder usingRetryStrategy () {
		event.IsRetryDisabled__c = false;
		return this; 		
	}	

	public EventBuilder disablingRetryStrategy () {
		event.IsRetryDisabled__c = true;
		return this; 		
	}	

	public EventBuilder withSender (String sender) {
		event.senderAccount__c = sender;
		return this; 		
	}
	
	public EventBuilder withReceiver (String receiver) {
		event.receiverAccount__c = receiver;
		return this; 		
	}
	
	//deprecated
	public EventBuilder withPayload (String payload) {
		event.payload__c = payload;
		return this; 		
	}	
	
	public EventBuilder withInternalID (String internalId) {
		event.internalId__c  = internalId;
		return this; 		
	}

	public EventBuilder withStatus (String status) {
		event.Status__c  = status;
		return this; 		
	}

	public EventBuilder withException (Exception ex) {
		event.ExceptionStackTrace__c  = ex.getStackTraceString();
		event.StatusMessage__c = ex.getMessage();
		return this; 		
	}

	public EventBuilder isSync () {
		event.IsSync__c  = true;
		return this; 		
	}

	public Queue__c build() {
		return event;
	}
	

}