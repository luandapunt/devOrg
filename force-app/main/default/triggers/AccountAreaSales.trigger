trigger AccountAreaSales on AccountAreaSales__c (before insert, before update, before delete, after insert, after update, after delete) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            AccountAreaSalesTriggerHandler.doBeforeInsert(Trigger.New, Trigger.oldMap);            
        }
        if(Trigger.isUpdate){
            AccountAreaSalesTriggerHandler.doBeforeUpdate(Trigger.New, Trigger.oldMap);            
        }
        if(Trigger.isDelete){
            
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            AccountAreaSalesTriggerHandler.doAfterInsert(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isUpdate){
            AccountAreaSalesTriggerHandler.doAfterUpdate(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isDelete){
            AccountAreaSalesTriggerHandler.doAfterDelete(Trigger.New, Trigger.oldMap);            
        }
    }
}