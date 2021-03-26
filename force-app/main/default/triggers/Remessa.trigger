trigger Remessa on Remittance__c (after delete, after insert, after update, before insert) {
    
    fflib_SObjectDomain.triggerHandler(RMTRemittanceDOM.class);
    
}