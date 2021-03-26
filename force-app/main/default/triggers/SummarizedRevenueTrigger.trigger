trigger SummarizedRevenueTrigger on SummarizedRevenue__c (before insert, before update, before delete, after insert, after update, after delete) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            SummarizedRevenueTriggerHandler.doBeforeInsert(Trigger.New, Trigger.oldMap);            
        }
        if(Trigger.isUpdate){
            SummarizedRevenueTriggerHandler.doBeforeUpdate(Trigger.New, Trigger.oldMap);            
        }
        if(Trigger.isDelete){ 
            
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            SummarizedRevenueTriggerHandler.doAfterInsert(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isUpdate){
            SummarizedRevenueTriggerHandler.doAfterUpdate(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isDelete){
            SummarizedRevenueTriggerHandler.doAfterDelete(Trigger.New, Trigger.oldMap);            
        }
    }
}