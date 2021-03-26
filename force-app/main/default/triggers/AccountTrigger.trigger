trigger AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            AccountTriggerHandler.doBeforeInsert(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isUpdate){
            AccountTriggerHandler.doBeforeUpdate(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isDelete){
            AccountTriggerHandler.doBeforeDelete(Trigger.New, Trigger.oldMap);
        }
    }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            AccountTriggerHandler.doAfterInsert(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isUpdate){
            AccountTriggerHandler.doAfterUpdate(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isDelete){
            AccountTriggerHandler.doAfterDelete(Trigger.New, Trigger.oldMap);
        }
    }
    
}