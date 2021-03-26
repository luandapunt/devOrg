global class Batch_CleanInvoice implements Database.Batchable<sObject>{
    ExpurgoNotaFiscal__c numDias = ExpurgoNotaFiscal__c.getInstance('DaysToPurgeInvoice');
	global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(
        	'SELECT ID FROM Invoice__c WHERE isDeleted = false AND CreatedDate <= LAST_N_DAYS:' + Integer.valueOf(numDias.Dias_para_expurgo__c)
        ); 
    }
    global void execute(Database.BatchableContext bc, List<Invoice__c> scope){
        delete scope;
    }
    global void finish(Database.BatchableContext bc){

    }

}