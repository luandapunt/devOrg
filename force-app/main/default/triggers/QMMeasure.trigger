trigger QMMeasure on QMMeasure__c (after delete, after insert, after update, before insert) {
    fflib_SObjectDomain.triggerHandler(QMMeasureDOM.class);
}