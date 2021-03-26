global class Batch_GenerateCreditNote implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc){
    	//System.debug('Batch_GenerateCreditNote start');
        return Database.getQueryLocator(
            'SELECT Id, BenefitPercentage__c, CalculationBasis__c, AccountLkp__c FROM AccountGoal__c WHERE CampaignCalculationLkp__r.EndDate__c <= TODAY '+
            'AND CreatedCreditNote__c = FALSE AND CampaignMechanicsLkp__r.BenefitCriteriaLkp__c <> null AND (RealizedPercentage__c >= 100 OR Status__c = \'Recuperado\')'
        );   
    }
    global void execute(Database.BatchableContext bc, List<AccountGoal__c> scope){
        List<CreditNote__c> credNoteList = new List<CreditNote__c>();
        
        //System.debug('Metas atingidas da campanha: '+scope.size());
        
        for(AccountGoal__C accGoal : scope){
            //System.debug('Porcentagem do Beneficio: '+ accGoal.BenefitPercentage__c);
            //System.debug('Base de Calculo: '+ accGoal.CalculationBasis__c);
            Double creditAmount = accGoal.BenefitPercentage__c/100 * accGoal.CalculationBasis__c;
            //System.debug('A ser pago : '+creditAmount);
            
            CreditNote__c credNote = new CreditNote__c();
            credNote.Value__c = creditAmount;
            credNote.AccountGoalLkp__c = accGoal.Id;
            credNote.AccountLkp__c = accGoal.AccountLkp__c;
            credNote.Date__c = Date.today();
            credNote.Status__c = 'Aprovado';
            
            credNoteList.add(credNote);
            
            accGoal.CreatedCreditNote__c = true;
        }
        insert credNoteList;
        update scope;
        
    }
    global void finish(Database.BatchableContext bc){
     	System.debug('Fim execução Batch Nota de Crédito');   
    }
}