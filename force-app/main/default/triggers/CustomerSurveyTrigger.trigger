trigger CustomerSurveyTrigger on CustomerSurvey__c (before insert, before update, before delete, after insert, after update, after delete) {
    
    if (Trigger.IsBefore){
        if (Trigger.IsInsert){
        	CustomerSurveyTriggerHandler.isBeforeInsert(Trigger.New, Trigger.OldMap);
        }
        if (Trigger.IsUpdate){
            CustomerSurveyTriggerHandler.isBeforeUpdate(Trigger.New, Trigger.OldMap);
        }
        if (Trigger.IsDelete){
            CustomerSurveyTriggerHandler.isBeforeDelete(Trigger.New, Trigger.OldMap);
        }        
    }
    
    if (Trigger.IsAfter){
        if (Trigger.IsInsert){
            CustomerSurveyTriggerHandler.isAfterInsert(Trigger.New, Trigger.OldMap);
        }
        if (Trigger.IsUpdate){
            CustomerSurveyTriggerHandler.isAfterUpdate(Trigger.New, Trigger.OldMap);
        }
        if (Trigger.IsDelete){
            CustomerSurveyTriggerHandler.isAfterDelete(Trigger.New, Trigger.OldMap);
        }
    }

}