/*
    Classe de DAO para objeto Case
    
    Dev: Renata
    Data: 24/01/2017
    =====================================
    Alteração: alteração do método getOrdersIdInCase() para retornar ordens que estão abertos ou fechadas do tipo 'Reclamação' ou 'Substituição'
    Dev: Carlos Diogo de Oliveira
    Data: 03/02/2017
*/
public class DAO_Case {
  
    public static Set<Id> getOrdersIdInCase() {
        List<Case> casos =  [SELECT Id
                                  , OrderLkp__r.Id
                                  , InvoiceLkp__r.RemittanceLkp__r.OrderLkp__r.Id 
                                  , isClosed
                                  , RecordType.Name
                                  , (SELECT Id FROM Ordens__r)
                             FROM Case 
                             WHERE (OrderLkp__c != null OR InvoiceLkp__c != null)];
                      
        Set<Id> ids = new Set<Id>();
        for (Case caso : casos){
            if ((caso.OrderLkp__r.Id != null 
                && !caso.isClosed)
                || (caso.isClosed && (caso.RecordType.Name == 'Reclamação' || caso.RecordType.Name == 'Substituição'))){
                ids.add(caso.OrderLkp__r.Id);
                    
                for(Order__c ordem: caso.Ordens__r){
                    ids.add(ordem.Id);
                }    
            }
            if ((caso.InvoiceLkp__r.RemittanceLkp__r.OrderLkp__r.Id != null 
                && !caso.isClosed)
                || (caso.isClosed && (caso.RecordType.Name == 'Reclamação' || caso.RecordType.Name == 'Substituição'))){
                ids.add(caso.InvoiceLkp__r.RemittanceLkp__r.OrderLkp__r.Id);
                    
                for(Order__c ordem: caso.Ordens__r){
                    ids.add(ordem.Id);
                }    
            }
        }
        return ids;
    }
    
    
    public static Set<Id> getOrdersIdInCaseLast30DAYS(){
        List<Case> casos =  [SELECT Id
                                , OrderLkp__r.Id
                                , InvoiceLkp__r.RemittanceLkp__r.OrderLkp__r.Id
                                , isClosed
                            FROM Case
                            WHERE (OrderLkp__c != null OR InvoiceLkp__c != null)
                                OR (OrderLkp__r.OrderDateDte__c = LAST_N_DAYS:30 
                                OR InvoiceLkp__r.RemittanceLkp__r.OrderLkp__r.OrderDateDte__c = LAST_N_DAYS:30)];
        
        Set<Id> ordersId = new Set<Id>(); 
        for (Case caso : casos){
            if (caso.OrderLkp__r.Id != null){
                ordersId.add(caso.OrderLkp__r.Id);
            }
            if (caso.InvoiceLkp__r.RemittanceLkp__r.OrderLkp__r.Id != null) {
                if (!caso.isClosed){
                    ordersId.add(caso.InvoiceLkp__r.RemittanceLkp__r.OrderLkp__r.Id);
                }   
            }
            
        }
        return ordersId;
    }
   
}