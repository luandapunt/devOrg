trigger Caso on Case (after delete, after insert, after update, before insert, before update) {

    fflib_SObjectDomain.triggerHandler(CSECaseDOM.class);

}