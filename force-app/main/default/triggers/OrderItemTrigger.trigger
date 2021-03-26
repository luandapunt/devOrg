trigger OrderItemTrigger on OrderItem__c (before insert, before update, before delete, after insert, after update, after delete) {
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            OrderItemTriggerHandler.isBeforeInsert(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isUpdate){
            OrderItemTriggerHandler.isBeforeUpdate(Trigger.New, Trigger.oldMap, Trigger.newMap);
        }
    }

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            OrderItemTriggerHandler.isAfterInsert(Trigger.New);
        }
        
        if(Trigger.isDelete){
            OrderItemTriggerHandler.isAfterDelete(Trigger.oldMap.values());
        }
    }
    
    
}