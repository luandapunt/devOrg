public with sharing class QMMeasureDOM extends fflib_SObjectDomain implements ITestAble {
    
    QMMeasureBO qmMeasureBo = new QMMeasureBO();
    
    public QMMeasureDOM(List<QMMeasure__c> sObjectList){
        super((List<SObject>)sObjectList);
    }

    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        if((existingRecords != null) && (!existingRecords.isEmpty())) {
            qmMeasureBo.concludeQM(existingRecords.keySet());
        }
    }
    
    public override void onAfterInsert() { 
    	Set<Id> qmMeasureIdSet = new Set<Id>();
        for (QMMeasure__c qmM : (List<QMMeasure__c>)records){
        	qmMeasureIdSet.add(qmM.Id);
        }
        qmMeasureBo.setQMSapNumber(qmMeasureIdSet);        
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new QMMeasureDOM(sObjectList);
        }
    }
    
    public static QMMeasure__c getSampleObject() {
        return new QMMeasure__c (); 
    } 
}