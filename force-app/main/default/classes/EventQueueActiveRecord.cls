public abstract with sharing class EventQueueActiveRecord {
	
	public void updateAll ( List<Queue__c> events ) {
		update events;
	}

	public Queue__c save (Queue__c event) {
		upsert event;
		return event;
	}
	
	public Queue__c save (Queue__c event, List<Attachment> attachList) {
		upsert event;
		storePayloads(event, attachList);
		return event;
	}

	public List<Queue__c> findAllQueuedEvents (Set<String> keys) {
		return [Select q.Status__c, 
					q.StatusMessage__c, 
					q.SenderAccount__c, 
					q.RetryCount__c, 
					q.ReceiverAccount__c, 
					q.Payload__c, 
					q.OwnerId, 
					q.ObjectId__c, 
					q.NotificationReceivers__c, 
					q.Name, 
					q.IsRetryDisabled__c, 
					q.InternalId__c, 
					q.Id, 
					q.ExternalCreationDate__c, 
					q.ExceptionStackTrace__c, 
					q.EventName__c, 
					(SELECT Id FROM Attachments LIMIT 1)
					From Queue__c q where q.id in :keys ] ; 
	}

	public List<Queue__c> findAllWithErrors () {
		return [

				Select q.Status__c, 
					q.StatusMessage__c, 
					q.SenderAccount__c, 
					q.RetryCount__c, 
					q.ReceiverAccount__c, 
					q.Payload__c, 
					q.OwnerId, 
					q.ObjectId__c, 
					q.NotificationReceivers__c, 
					q.Name, 
					q.IsRetryDisabled__c, 
					q.InternalId__c, 
					q.Id, 
					q.ExternalCreationDate__c, 
					q.ExceptionStackTrace__c, 
					q.EventName__c
					FROM Queue__c q 
					WHERE Status__c = 'ERROR'
					LIMIT 50000
				] ; 
	}

	public Queue__c findOne (String id) {
		List<Queue__c> queues = findAllQueuedEvents ( new Set<String> {id});
		return (!queues.isEmpty()) ? queues.get(0) : null ; 
	}
	
	public void storePayloads (Queue__c queue, List<Attachment> payloads) {
		if (payloads.size() == 0) return; 
		for (Attachment attach : payloads) {
			if (attach.ParentId == null) {
				attach.ParentId = queue.id;
			}
		}
		upsert payloads;  
	}
	
	public void storePayloads (List<Attachment> payloads) {
		if (payloads.size() == 0) return; 
		upsert payloads;  
	}

}