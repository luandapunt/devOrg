trigger CreditNoteTrigger on CreditNote__c (before insert, before update, before delete, after insert, After update, after delete) {
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            CreditNoteTriggerHandler.isBeforeInsert(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isUpdate){
            CreditNoteTriggerHandler.isBeforeUpdate(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isDelete){
            CreditNoteTriggerHandler.isBeforeDelete(Trigger.New, Trigger.oldMap);
        }
    }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            CreditNoteTriggerHandler.isAfterInsert(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isUpdate){
            CreditNoteTriggerHandler.isAfterUpdate(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isDelete){
            CreditNoteTriggerHandler.isAfterDelete(Trigger.New, Trigger.oldMap);
        }
    }

}