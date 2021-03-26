public with sharing class QMMeasureDAO {
    
    public static List<QMMeasure__c> getById(Set<Id> qmMeasureIdSet) {
        return [
            SELECT Id,
            	   QMSalesforceMdt__c,
            	   StatusTxt__c
            FROM QMMeasure__c
            WHERE Id IN :qmMeasureIdSet
        ];      
    }

    public static List<QMMeasure__c> getByQmId(Set<Id> qmIdSet) {
        return [
            SELECT Id,
            	   QMSalesforceMdt__c,
            	   StatusTxt__c
            FROM QMMeasure__c
            WHERE QMSalesforceMdt__c IN :qmIdSet
        ];      
    }
}