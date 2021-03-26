trigger VerdeAmancoKitTrigger on VerdeAmancoKit__c (before insert, before update, before delete, after insert, After update, after delete) {

    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            VerdeAmancoKitTriggerHandler.isBeforeInsert(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isUpdate){
            VerdeAmancoKitTriggerHandler.isBeforeUpdate(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isDelete){
            VerdeAmancoKitTriggerHandler.isBeforeDelete(Trigger.New, Trigger.oldMap);
        }
    }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            VerdeAmancoKitTriggerHandler.isAfterInsert(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isUpdate){
            VerdeAmancoKitTriggerHandler.isAfterUpdate(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isDelete){
            VerdeAmancoKitTriggerHandler.isAfterDelete(Trigger.New, Trigger.oldMap);
        }
    }
}