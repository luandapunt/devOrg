/*
    Rotinas de limpeza:
    PurgeOrderItemSchedule + Batch_OrderItem
    PurgeOrderSchedule + PurgeOrderBatch
    PurgeInvoiceSchedule + Batch_Invoice
    PurgeOrderRemittanceSchedule + PurgeOrderRemittanceBatch

    Data: 23/01/2017
    Dev: Renata
    Caso: 00025639
    Objetivo: Excluir Itens das ordens que estejam relacionadas aos casos, desde que o caso já esteja fechado
    ===============================================
    
    Data: 02/02/2017
    Dev: Carlos Diogo de Oliveira
    Caso : 00025639
    Alteração: Excluir Itens das ordens que estejam relacionadas aos casos, desde que o caso já esteja fechado e não seja do tipo "Reclamação" ou "Substituição"
*/
global class Batch_OrderItem implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Itens que nao podem ser excluídos
        Set<Id> ids = DAO_Case.getOrdersIdInCase();
        
        // Itens para excluir
        return Database.getQueryLocator([SELECT Id 
                                         FROM OrderItem__c  
                                         WHERE OrderMdt__r.Id NOT IN : ids
                                         AND OrderMdt__r.CreatedDate < LAST_N_DAYS:30
                                         AND (OrderMdt__r.CaseLkp__r.Id != null 
                                              AND OrderMdt__r.CaseLkp__r.IsClosed = true 
                                              AND OrderMdt__r.CaseLkp__r.RecordType.Name != 'Reclamação'
                                              AND OrderMdt__r.CaseLkp__r.RecordType.Name != 'Substituição')]);
    }

    global void execute(Database.BatchableContext BC, List<OrderItem__c> OrderItemList) {
        System.debug(OrderItemList.size());
        
        Database.delete(OrderItemList);

    }
    
    global void finish(Database.BatchableContext BC) {
     
    }
    
}