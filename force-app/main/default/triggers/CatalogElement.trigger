trigger CatalogElement on CatalogElement__c (after insert, after update) {

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            List<Id> listIds = new List<Id>();
            for(CatalogElement__c elem : Trigger.New){
                if(elem.ParentElementLkp__c != null)
                    listIds.add(elem.ParentElementLkp__c);
                else listIds.add(elem.PricebookLkp__c);
            }
            if(listIds.size() > 0)
                CatalogElementTriggerHandler.processOrder(listIds);
        }
        if(Trigger.isUpdate){
            List<Id> listIds = new List<Id>();
            for(CatalogElement__c elem : Trigger.New){
                if(elem.IndexNmb__c != Trigger.oldMap.get(elem.Id).IndexNmb__c){
                    if(elem.ParentElementLkp__c != null)
                        listIds.add(elem.ParentElementLkp__c);
                    else listIds.add(elem.PricebookLkp__c);
                }
            }
            if(listIds.size() > 0)
                CatalogElementTriggerHandler.processOrder(listIds);
        }
    }
    
}