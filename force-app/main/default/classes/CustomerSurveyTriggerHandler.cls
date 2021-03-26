public class CustomerSurveyTriggerHandler {
    
    public static void isBeforeInsert (List<CustomerSurvey__c> listCustomerSurvey, Map<Id, CustomerSurvey__c> oldMap){
        
    }
    
    public static void isBeforeUpdate (List<CustomerSurvey__c> listCustomerSurvey, Map<Id, CustomerSurvey__c> oldMap){
        List<CustomerSurvey__c> listSurvIds = new List<CustomerSurvey__c>();
        
        for(CustomerSurvey__c surv : listCustomerSurvey){
            system.debug(surv.name);
            if(surv.StatusTxt__c == 'Completa' && oldMap.get(surv.Id).StatusTxt__c != 'Completa')
                listSurvIds.add(surv);
        }
                
        for(CustomerSurvey__c surv : [SELECT ID, (SELECT Id FROM ContentDocumentLinks) FROM CustomerSurvey__c WHERE ID IN :listSurvIds LIMIT 1]){
            if(surv.ContentDocumentLinks.size() == 0){
                //oldMap.get(surv.Id).addError('É necessário adicionar ao menos um anexo para finalizar a pesquisa');
                listCustomerSurvey[0].addError('É necessário adicionar ao menos um anexo para finalizar a pesquisa');
            }
        }    
    }
    
    public static void isBeforeDelete (List<CustomerSurvey__c> listCustomerSurvey, Map<Id, CustomerSurvey__c> oldMap){
        
    }
    
    public static void isAfterInsert (List<CustomerSurvey__c> listCustomerSurvey, Map<Id, CustomerSurvey__c> oldMap){
        
    }
    
    public static void isAfterUpdate (List<CustomerSurvey__c> listCustomerSurvey, Map<Id, CustomerSurvey__c> oldMap){
        
    }
    
    public static void isAfterDelete (List<CustomerSurvey__c> listCustomerSurvey, Map<Id, CustomerSurvey__c> oldMap){
        
    }

}