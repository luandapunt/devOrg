trigger VerdeAmancoSolicitationTrigger on VerdeAmancoSolicitation__c (before insert, before update, before delete, after insert, After update, after delete) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            VerdeAmancoSolicitationTriggerHandler.isBeforeInsert(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isUpdate){
            VerdeAmancoSolicitationTriggerHandler.isBeforeUpdate(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isDelete){
            VerdeAmancoSolicitationTriggerHandler.isBeforeDelete(Trigger.New, Trigger.oldMap);
        }
    }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            VerdeAmancoSolicitationTriggerHandler.isAfterInsert(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isUpdate){
            VerdeAmancoSolicitationTriggerHandler.isAfterUpdate(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isDelete){
            VerdeAmancoSolicitationTriggerHandler.isAfterDelete(Trigger.New, Trigger.oldMap);
        }
    }
}