global class Batch_CleanSummarizedRevenue implements Database.Batchable<sObject> {
    
    ExpurgoFaturamentoSumarizado__c numDias = ExpurgoFaturamentoSumarizado__c.getInstance();
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(
            'SELECT ID FROM SummarizedRevenue__c WHERE isDeleted = false AND CreatedDate <= LAST_N_DAYS:' + Integer.valueOf(numDias.Dias_para_expurgo__c)
        ); 
    }
    global void execute(Database.BatchableContext bc, List<SUmmarizedRevenue__c> scope){
        delete scope;
    }
    global void finish(Database.BatchableContext bc){
        
    }
}