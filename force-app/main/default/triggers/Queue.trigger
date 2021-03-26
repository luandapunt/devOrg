/**
 *
 */
 
trigger Queue on Queue__c (after insert , after update) {
	 fflib_SObjectDomain.triggerHandler(integ_QueueDOM.class);
}