global class Batch_CleanIntegrationItem implements Database.Batchable<sObject> {
    ExpurgoItemDaIntegracao__c numDias = ExpurgoItemDaIntegracao__c.getInstance('DaysToPurgeIntegrationItem');
	global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(
        	'SELECT ID FROM Queue__c WHERE isDeleted = false AND CreatedDate <= LAST_N_DAYS:' + Integer.valueOf(numDias.DiasParaExpurgo__c)
        ); 
    }
    global void execute(Database.BatchableContext bc, List<Queue__c> scope){
        delete scope;
    }
    global void finish(Database.BatchableContext bc){

    }

}