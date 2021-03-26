public class AccountGoalTriggerHandler {
/*    public static void isAfterInsert(List<AccountGoal__c> listAccGoal, Map<Id, AccountGoal__c> oldMap){
        
    }
    public static void isAfterUpdate(List<AccountGoal__c> listAccGoal, Map<Id, AccountGoal__c> oldMap){
       
        List<AccountGoal__c> listFlexAccGoal = new List<AccountGoal__c>();
        
        for(AccountGoal__c accGoal : listAccGoal){
            if(accGoal.Status__c == 'Flexibilizado' && (accGoal.Status__c != oldMap.get(accGoal.Id).Status__c)
              && (accGoal.BenefitPercentage__c != null) && (accGoal.RealizedPercentage__c == 100)){
                listFlexAccGoal.add(accGoal);
            }
        }
        System.debug('Trigger after AccountGoal update - '+listFlexAccGoal.size()+' records');
        if(listFlexAccGoal.size() > 0){
            //System.debug('UPDATE DE FLEXIBILIZADO!!!');
            List<CreditNote__c> listCreditNote = new List<CreditNote__c>();
			      
            for(AccountGoal__c accGoal : listFlexAccGoal){
                //System.debug(accGoal);
           		CreditNote__c credNote = new CreditNote__c();
                credNote.Value__c = accGoal.CalculationBasis__c * accGoal.BenefitPercentage__c/100;
                credNote.AccountGoalLkp__c = accGoal.Id;
                credNote.AccountLkp__c = accGoal.AccountLkp__c;
                credNote.Date__c = Date.today();
                credNote.Status__c = 'Aprovado';
                
                listCreditNote.add(credNote);
            }
            Database.insert(listCreditNote);
        }        
    }
    public static void isAfterDelete(List<AccountGoal__c> listAccGoal, Map<Id, AccountGoal__c> oldMap){
        
    }*/
}