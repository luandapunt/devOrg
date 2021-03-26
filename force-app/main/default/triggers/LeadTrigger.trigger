trigger LeadTrigger on Lead (before insert, before update, before delete, after insert, After update, after delete) {
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            LeadTriggerHandler.isBeforeInsert(Trigger.New, Trigger.oldMap);
        }
    }
    
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            LeadTriggerHandler.isBeforeUpdate(Trigger.New, Trigger.oldMap);
        }
        
    }
    
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            LeadTriggerHandler.isAfterUpdate(Trigger.New, Trigger.oldMap);
        }
        
    }
    
}