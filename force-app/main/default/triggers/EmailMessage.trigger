trigger EmailMessage on EmailMessage (after insert) {

	fflib_SObjectDomain.triggerHandler(CSEEmailMessageDOM.class);
}