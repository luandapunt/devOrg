/*
    Rotinas de limpeza:
    PurgeOrderItemSchedule + PurgeOrderItemBatch
    PurgeOrderSchedule + PurgeOrderBatch
    PurgeInvoiceSchedule + Batch_Invoice
    PurgeOrderRemittanceSchedule + PurgeOrderRemittanceBatch

    Data: 23/01/2017
    Dev: Renata
    Caso: 00025639
    Objetivo: Excluir as notas fiscais que não tem relacionamento com ordens nem casos
*/
global class Batch_Invoice implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator([SELECT Id 
                                        FROM Invoice__c 
                                        WHERE OrderLkp__c = null 
                                            AND DocumentDateDte__c < LAST_N_DAYS:30
                                            AND Id NOT IN (SELECT InvoiceLkp__c FROM Case) ]);
    }

    global void execute(Database.BatchableContext BC, List<Invoice__c> invoiceList) {
        System.debug(invoiceList.size());
        
        Database.delete(invoiceList);

    }
    
    global void finish(Database.BatchableContext BC) {
     
    }
    
}