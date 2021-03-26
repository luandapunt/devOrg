/*
    Rotinas de limpeza:
    PurgeOrderItemSchedule + Batch_OrderItem
    PurgeOrderSchedule + PurgeOrderBatch
    PurgeInvoiceSchedule + Batch_Invoice
    PurgeOrderRemittanceSchedule + PurgeOrderRemittanceBatch

    Data: 02/02/2017
    Dev: Carlos Diogo de Oliveira
    Caso : 00025639
    Objetivo: Excluir Itens das remessas que estejam relacionadas aos casos, desde que o caso já esteja fechado e não seja do tipo "Reclamação" ou "Substituição"
*/

global class Batch_RemittanceItem implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Itens que nao podem ser excluídos
        Set<Id> ids = DAO_Case.getOrdersIdInCase();
        
        // Itens para excluir
        return Database.getQueryLocator([SELECT Id 
                                         FROM RemittanceItem__c  
                                         WHERE RemittanceMdt__r.OrderLkp__r.Id NOT IN : ids
                                         AND RemittanceMdt__r.OrderLkp__r.CreatedDate < LAST_N_DAYS:30
                                         AND (RemittanceMdt__r.OrderLkp__r.CaseLkp__r.Id != null 
                                              AND RemittanceMdt__r.OrderLkp__r.CaseLkp__r.IsClosed = true 
                                              AND RemittanceMdt__r.OrderLkp__r.CaseLkp__r.RecordType.Name != 'Reclamação'
                                              AND RemittanceMdt__r.OrderLkp__r.CaseLkp__r.RecordType.Name != 'Substituição')]);
    }

    global void execute(Database.BatchableContext BC, List<RemittanceItem__c> remittanceItemList) {
        System.debug(remittanceItemList.size());
        
        Database.delete(remittanceItemList);
    }
    
    global void finish(Database.BatchableContext BC) {}
}