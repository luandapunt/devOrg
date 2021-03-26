/**
 * @author: Eduardo R Carvalho/ Diéffrei
 * @date: 10/12/2015
 * @description:
 */
 global with sharing class EventQueue extends EventQueueActiveRecord {
 	
 	public class EventQueueException extends Exception {}
 	
 	private Map<String, TransformerAbstract> transformerMap; 
	private Map<IntegrationOperationType, integ_IIntegrationOperation> intOpMap; 
	
	public class UnhandleOperation implements integ_IIntegrationOperation {
		public Object execute(List<SObject> recordList) {
			throw new integ_UnhandledOperationException('It doesnt support upsert');
			return null;
		}
	}

    webservice String id                      {get;set;}
    webservice String eventName               {get;set;}
    webservice String sender                  {get;set;}
    webservice String receiver                {get;set;}
    webservice String eventId                 {get;set;}
    webservice String internalId              {get;set;}
    webservice String status                  {get;set;}
    webservice String statusMessage           {get;set;}

    public List<Attachment> payloads      {get;set;}
    
    public String authenticationToken  {get;set;}

	public Queue__c event {get;set;}
	public String payloadData {get;set;}

	public IntegrationMap__c deliveryInfo {get;set;}

	public EventQueueCommandMappping commandMapping;

	public static EventQueue instance = new EventQueue();

	public EventQueue() {
		commandMapping = new EventQueueCommandMappping();
		payloads =  new List<Attachment>();

 		this.intOpMap = new Map<IntegrationOperationType, integ_IIntegrationOperation> {
			IntegrationOperationType.UPSERTZ => new UnhandleOperation(),
			IntegrationOperationType.INSERTZ => new IntegrationOperationInsert(),
			IntegrationOperationType.UPDATEZ => new UnhandleOperation(),
			IntegrationOperationType.DELETEZ => new UnhandleOperation()
		};	
		
		this.transformerMap = new Map<String, TransformerAbstract> {
			IntegrationOutputDataType.JSON.name() => new integ_JSONTransformer(), 
			IntegrationOutputDataType.CSV.name() => new integ_CSVTransformer() 
		};		
		
	}

	public EventQueue(Queue__c event) {
		this();
		this.event = event;
	}

    public EventQueue(String id) {
		this();
		this.event = findOne(id);
	}


	public Queue__c getQueue(){
		return this.event;
	}

	public String getReceiver (){
		return event.receiverAccount__c;
	}

	//deprecated
	public String getPayload() {
		return this.payloadData;
	}

	public String getEventName() {
		return this.event.eventName__c;
	}

    public void setEventName(String eventName) {
		this.event.eventName__c = eventName;
	}


	public void setSoapPayload (Dom.Document request) {
		this.event.soapPayload__c = request.toXmlString();
	}

	public String getSoapPayload() {
		return this.event.soapPayload__c;
	}

	public void  buildFromExternalEvent(EventQueue event) {

		EventBuilder builder = new EventBuilder();

		this.event = builder.createEventFor(event.eventName)
									 .withInternalID(event.internalId)
									 .withSender(event.sender)
									 .withReceiver(event.receiver)
									 .build();

	}

	public void save() {
		if (event == null) return;
		save(event, payloads);
	}

	/**
	 * Processar todos os eventos em um escopo futuro
	 * @param Map<String, String> - devera ser envido os dados Id do Evento e Nome do Evento.
	 */
	@future(callout=true)
	public static void processEvents(Map<String, String> events) {
    	List<Queue__c> processingQueue = instance.findAllQueuedEvents(events.keySet());
		instance.processEvents(processingQueue);
	}

	public static void processEventsSync(Map<String, String> events) {
    	List<Queue__c> processingQueue = instance.findAllQueuedEvents(events.keySet());
		instance.processEvents(processingQueue);
	}

	public void processEvents (List<Queue__c> events ) {

		//List<Attachment> payloads = new List<Attachment>();
		Map<Id, Attachment> payloadMapByQueueItemId = new Map<Id, Attachment>();
		
		List<Attachment> attachList = new List<Attachment>();
		
		Set<Id> attachSetId = new Set<Id>();
		
		for (Queue__c event : events) {
			if (event.Attachments.isEmpty()) {
				throw new EventQueueException('Payload attachment not found.');
			}
			attachSetId.add(event.Attachments[0].Id);
		}

		attachList = [SELECT Id, Body FROM Attachment where Id IN :attachSetId];
		Map<Id, Attachment> attachMap = new Map<Id, Attachment>(attachList); 

		for (Queue__c event : events) {
			EventQueue eventQueue = new EventQueue(event);
			Attachment payloadFile = attachMap.get(event.Attachments[0].Id);
			String payload = payloadFile.Body.toString();
			eventQueue.enrichQueueWithPayload(payload);
			processEvent(eventQueue);
            //payloads.addAll(eventQueue.payloads);
		}

		updateAll(events);

		//storePayloads(payloads);
	}
	
	public Queue__c enrichQueueWithPayload(String payload) {
		this.payloadData = payload;
		return this.event;
	}
	

    public Object processEvent() {
        Object result = processEvent(this);
        save();
        return result;
    }


	public Object processEvent(EventQueue eventQueue) {

		if (isUnhadledEvent(eventQueue)) {
			unhadledEvent(eventQueue.event);
			return null;
		}

		try {
			
			/*
				Get integration order,
				if is there predecessor integrations (child)
				Like Invoice, InvoiceItems
			*/
			
			List<String> eventNameExecutionOrder = commandMapping.getEventListOrderExecution(eventQueue.getEventName());
			
			for (String currentEventName : eventNameExecutionOrder) {

				IntegrationMap__c integrationMapInfo = commandMapping.getDeliveryInfoFor(currentEventName);
				
				//get transformer instance by outputdata type
				TransformerAbstract transf = this.transformerMap.get(integrationMapInfo.OutputDataTypeTxt__c);
				
				//execute integration interface
				IIntegrationService integrationService = this.getCommand(currentEventName);
				
				//todo refactor to op map conditions
				integ_IIntegrationOperation operation = null;
				if (integrationMapInfo.DMLOperationTxt__c == 'Custom') {
					if (integrationMapInfo.CustomOperationClassName__c != null) {
						Type operationClass = Type.forName(integrationMapInfo.CustomOperationClassName__c);
						operation = (integ_IIntegrationOperation) operationClass.newInstance();
					}
				} else if (integrationMapInfo.DMLOperationTxt__c == 'Insert') {
					operation =  new IntegrationOperationInsert();
				} else {
					throw new integ_UnhandledOperationException('Operation is not implemented yet.'
						+ 'EventName [' + currentEventName + ']' + 
						+' If operation is custom, ensure if CustomOperationClassName__c field is correct.');    		
					
				}
				
				integrationService.execute(eventQueue, transf, operation, integrationMapInfo);
				
			}
			
			eventQueue.successfullyDeliveyEvent();

		} catch (CalloutEventException e) {
			eventQueue.errorProcessingEvent(e);
		} catch (Exception e) {
			eventQueue.errorProcessingEvent(e);
		}
		
		return null;

	}
	
	public void dispatch() {
		event.status__c = EventQueueStatusType.QUEUED.name();
		save();
	}

	public boolean isUnhadledEvent (EventQueue event) {
		return !commandMapping.hasHandlerFor (event);
	}

	public IIntegrationService getCommand (String eventName) { 
		return commandMapping.getCommand(eventName);
	}

	public Queue__c unhadledEvent (Queue__c event) {
		event.status__c = EventQueueStatusType.UNHANDLED.name();
		return event;
	}

	public Queue__c successfullyProcessedEvent () {
		event.Status__c = EventQueueStatusType.SUCCESS.name();
		event.StatusMessage__c = '';
		event.ExceptionStackTrace__c = '';
		return event;
	}

	public Queue__c successfullyDeliveyEvent (){
		event.Status__c = EventQueueStatusType.DELIVERED.name();
		event.StatusMessage__c = '';
		event.ExceptionStackTrace__c = '';
		return event;
	}

	public Queue__c successfullyDeliveyEvent (Object records){
		event.Status__c = EventQueueStatusType.DELIVERED.name();
		event.StatusMessage__c = '';
		event.ExceptionStackTrace__c = '';
		
		insert new Attachment(ParentId = event.id , Name = 'Response.txt', Body = Blob.valueOf(JSON.serialize(records)));
		
		return event;
	}

	public void addPayload(String name, String content) {
		payloads.add(new Attachment(ParentId = event.id , Name = name + '.txt', Body = Blob.valueOf(content)));
	}

	public EventQueue errorProcessingEvent (CalloutEventException e){
		errorProcessingEvent (event, e);
		return this;
	}

	public EventQueue errorProcessingEvent (Exception e){
		errorProcessingEvent (event, e);
		return this;
	}

	public Queue__c errorProcessingEvent (Queue__c event, CalloutEventException cause){
		event.IsRetryDisabled__c = false;
		event = enrichQueueWithException(event, cause);
		return event;
	}

	public Queue__c errorProcessingEvent (Queue__c event, Exception e){
		System.debug( e.getMessage() );
		event.IsRetryDisabled__c = false;
		event = enrichQueueWithException(event, e);
		return event;
	}

	public Queue__c enrichQueueWithException (Queue__c event, Exception cause) {
		event.status__c = EventQueueStatusType.ERROR.name();
		event.statusMessage__c = cause.getTypeName() + ' : ' + cause.getMessage();
		event.statusMessage__c =  truncateLargeText (event.statusMessage__c );

		event.exceptionStackTrace__c = truncateLargeText (  cause.getStackTraceString() );
		return event;
	}

	public Queue__c enrichQueueWithException (Queue__c event, CalloutEventException cause) {
		event.status__c = EventQueueStatusType.ERROR.name();
		event.statusMessage__c = cause.getTypeName() + ' : ' + cause.getMessage() + '\n ---------\n' + cause.response;
		event.statusMessage__c =  truncateLargeText (event.statusMessage__c );
		event.exceptionStackTrace__c = truncateLargeText (  cause.getStackTraceString() );
		return event;
	}

	public EventQueue withDeliveryInfo () {
		deliveryInfo = commandMapping.getDeliveryInfoFor(getEventName());
		return this;
	}

	@testVisible
	private String truncateLargeText ( String value ) {
		if (value  == null ||  value == '') return  value;
		return ( value.length() > 30000 ) ? value.substring(0, 25000) :  value;
	}

}