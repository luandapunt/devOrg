public with sharing class CreateNewCaseCtrl {
    
    @AuraEnabled
    public static Invoice__c getinvoice(Id invoiceId) {
        system.debug('invoiceId'+ invoiceId);      
        
        Invoice__c invoice = [
            
            SELECT Id,Name,AccountLkp__c,OrderLkp__c,CarrierLkp__c,RemittanceLkp__c,RemittanceLkp__r.OrderLkp__r.SellerLkp__c,CarrierLkp__r.EmailTxt__c,RemittanceLkp__r.OrderLkp__r.SellerLkp__r.SellerEmailTxt__c,RemittanceLkp__r.OrderLkp__r.SellerLkp__r.ManagerEmailTxt__c,RemittanceLkp__r.OrderLkp__r.SellerLkp__r.CoordinatorEmailTxt__c
            FROM Invoice__c
            WHERE Id = :invoiceId
        ];
        
        system.debug('invoice' + invoice);
        return invoice;
        
    }
    
    @AuraEnabled
    public static Order__c getorder(Id orderId) {
        system.debug('orderId'+ orderId);      
        
        Order__c order = [
            
            SELECT Id,Name,AccountLkp__c,SellerLkp__r.SellerEmailTxt__c,SellerLkp__r.CoordinatorEmailTxt__c 
            FROM Order__c
            WHERE Id = :orderId
        ];
        
        system.debug('order' + order);
        return order;
        
    }
    
    
    @AuraEnabled
    public static List<RecordType> getcaserecordtype() {     
        List<RecordType> caserecordtype = [
            SELECT Id, Name 
            FROM RecordType 
            WHERE SobjectType = 'Case' 
            AND IsActive = true
            AND Name IN ('Devolução', 'Carta de correção', 'Prorrogação', 'Transtorno na entrega', 
                         'Sustação', 'Extravio de nota fiscal', 'Sinistro', 'Produto Trocado', 
                         'Refaturamento', 'Reposição', 'Substituição', 'Informações Gerais')
            ORDER BY Name ASC
        ];
        system.debug('caserecordtype'+ caserecordtype);
        return caserecordtype;
    }
    
    @AuraEnabled
    public static List <RecordType> getcaserecordtypeO() {     
        List<RecordType> caserecordtypeO = [
            SELECT Id, Name 
            FROM RecordType 
            WHERE SobjectType = 'Case' 
            AND IsActive = true
            AND Name IN ('Consulta de pedido','Alteração de pedido','Cancelamento de pedido', 'Informações Gerais')
            ORDER BY Name ASC
            
        ];
        system.debug('caserecordtypeO'+ caserecordtypeO);    
        return caserecordtypeO;
        
    }
    
    @AuraEnabled
    public static List<RecordType> getcaserecordtypeA() {     
        List<RecordType> caserecordtypeA = [
            SELECT Id, Name 
            FROM RecordType 
            WHERE SobjectType = 'Case' 
            AND IsActive = true
            AND Name IN ('Indicação de vendedor', 'Informações Gerais', 'Indicação BNDES','Reclamação contra o vendedor')
            ORDER BY Name ASC
        ];
        system.debug('caserecordtypeA'+ caserecordtypeA);
        return caserecordtypeA;
    }
    
}