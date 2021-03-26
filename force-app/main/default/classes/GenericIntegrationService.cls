public with sharing class GenericIntegrationService implements IIntegrationService {
	public void execute (EventQueue event, TransformerAbstract transformer, integ_IIntegrationOperation operation, IntegrationMap__c integMap) {
    	List<SObject> sobjList = transformer.convertToSObjectList(integMap, event.getPayload());
		operation.execute(sobjList);
	}
}